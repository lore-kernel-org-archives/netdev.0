From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: Is there a preferred way to get the VXLAN port number?
Date: Wed, 27 Mar 2013 15:01:51 -0400
Message-ID: <OFAA2F59A9.3D5AC989-ON85257B3B.00666533-85257B3B.00688855@us.ibm.com>
References: <51521B05.6060401@intel.com> <CAEP_g=9cXwxNE=Fxis2F_qStp1gPsjyXr2wE2agHO9rLZcquXA@mail.gmail.com> <51533B5B.9030405@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: David Miller <davem@davemloft.net>, Jesse Gross <jesse@nicira.com>,
	"Gasparakis, Joseph" <joseph.gasparakis@intel.com>,
	netdev <netdev@vger.kernel.org>, netdev-owner@vger.kernel.org,
	pshelar@nicira.com, Stephen Hemminger <shemminger@vyatta.com>
To: Alexander Duyck <alexander.h.duyck@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e37.co.us.ibm.com ([32.97.110.158]:42533 "EHLO
	e37.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753906Ab3C0TL4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Mar 2013 15:11:56 -0400
Received: from /spool/local
	by e37.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <dlstevens@us.ibm.com>;
	Wed, 27 Mar 2013 13:11:53 -0600
In-Reply-To: <51533B5B.9030405@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

netdev-owner@vger.kernel.org wrote on 03/27/2013 02:32:59 PM:
 
> The main think I want to do is keep this simple since I would prefer to
> not build up any infrastructure that will just get in the way.  My
> thought for now is to just export a function to allow drivers to fetch
> the port number of VXLAN.  The only downside is that it forces the VXLAN
> module to load if a driver comes up with offload support, similar to how
> we have been loading the 8021q module for many of the drivers that
> support VLAN offloads.  Hopefully if the fixed port number approach wins
> out we can simplify things by replacing the function call with a static
> define. 

        I guess you mean you need to find it within the kernel.

        I think whether or not it remains a single port for the machine,
it would be just silly to make it a fixed port, period. Virtually any
service allows an administrator to specify an alternate port to run a
service on.
        I think one of the primary reasons is that you may want to run
more than one instance on the same host (e.g., a sandbox installation
alongside a production installation) -- a capability not there now,
even though you can specify an alternate port now.
        But if for whatever reason an adminstrator cares that it uses
a particular port number, even in a single instance, there is no
technical reason to disallow it. It'd be bad to assume all VXLAN
must be on the particular port, and equally bad to assume all traffic
for that port is VXLAN (esp. on a host that is not using VXLAN at all,
but very well may want to use a lot of ports, including 8472).

        I think it ought to be fully general -- different devices may
use different ports and one device may use multiple listeners on different
ports (to split flows for security, load balancing, or whatever).
        I'd make it a per-device function interface that gives you a port 
list
for that device (e.g., an array and length or count). Right now, all 
devices
would return the single module parameter value, but in the future those 
ought
to be capable of being entirely distinct lists of ports.

                                                                +-DLS
