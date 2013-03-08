From: Andy Gospodarek <andy@greyhouse.net>
Subject: Re: [PATCH net-next] bond: add support to read speed and duplex via
 ethtool
Date: Fri, 8 Mar 2013 10:35:05 -0500
Message-ID: <20130308153505.GB7606@gospo.rdu.redhat.com>
References: <1362595173-11442-1-git-send-email-andy@greyhouse.net>
 <22416.1362597912@death.nxdomain>
 <20130306200140.GB19544@gospo.rdu.redhat.com>
 <27035.1362606373@death.nxdomain>
 <58A138EA-ADB5-4DFC-AA35-2D0E578483FD@gdt.id.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Glen Turner <gdt@gdt.id.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:25455 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759664Ab3CHPji (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 Mar 2013 10:39:38 -0500
Content-Disposition: inline
In-Reply-To: <58A138EA-ADB5-4DFC-AA35-2D0E578483FD@gdt.id.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 07, 2013 at 10:41:57PM +1030, Glen Turner wrote:
> Hi Andy,
> 
> How does this relate to the bandwidth metric for an interface as seen by routing daemons?
> 
> An interface bandwidth as seen by routing daemons cannot change once carrier is up. Otherwise flaps of a link within a bond will cause routing protocol flaps; which they do not do at the moment, and which would be deeply, deeply undesirable.
> 

That is a great point.  Are you saying that quagga or other
outside-the-kernel routing daemons actually query ethtool settings to
determine link speed and weight?  How do they handle interfaces like
bonds and vlans that do not return a speed?

> I'd just add the maximum possible bandwidth of the interfaces, rather than the negotiated value. That's enough to get SNMP graphs working reasonably. It's not clear that a SNMP grapher will have reasonable behaviour with a changing bandwidth -- you'll end up with graphs where absolute throughput appears to fall, but what has happened is that a link has come online and utilisation has fallen. That's not a useful graph, as it's very much the "shape" of the traffic which is useful.
> 
> Checked IOS and JUNOS. In the absence of nerd knobs, both report the sum of the maximum possible interface bandwidths. So that's probably the behaviour SNMP graphing tools expect in any case.
> 

Do they look at the maximum capabilities of the interfaces to determine
this maximum speed?  Right now bonding just queries the speed that is
actually connected.  I'm not sure I want to get into the business of
reporting possible maximum bandwidth as that seems invalid -- even when
considering the routing case.
