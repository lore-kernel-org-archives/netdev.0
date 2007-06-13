From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH] NET: Multiqueue network device support.
Date: Wed, 13 Jun 2007 09:33:22 -0400
Message-ID: <1181741602.4050.116.camel@localhost>
References: <466DEF9D.9070509@trash.net>
	 <1181615384.4071.121.camel@localhost> <466E9DF2.9010505@trash.net>
	 <20070612.140240.00078635.davem@davemloft.net> <466F0D74.5030308@trash.net>
	 <1181714168.4758.57.camel@debian.sh.intel.com>
	 <1181737935.4050.87.camel@localhost>
	 <18031.60741.695897.572432@robur.slu.se>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Zhu Yi <yi.zhu@intel.com>,
	Leonid Grossman <Leonid.Grossman@neterion.com>,
	Patrick McHardy <kaber@trash.net>,
	David Miller <davem@davemloft.net>,
	peter.p.waskiewicz.jr@intel.com, netdev@vger.kernel.org,
	jeff@garzik.org, auke-jan.h.kok@intel.com
To: Robert Olsson <Robert.Olsson@data.slu.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wr-out-0506.google.com ([64.233.184.239]:63611 "EHLO
	wr-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752193AbXFMNd0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Jun 2007 09:33:26 -0400
Received: by wr-out-0506.google.com with SMTP id 76so161691wra
        for <netdev@vger.kernel.org>; Wed, 13 Jun 2007 06:33:26 -0700 (PDT)
In-Reply-To: <18031.60741.695897.572432@robur.slu.se>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Wow - Robert in the house, I cant resist i have to say something before
i run out;->

On Wed, 2007-13-06 at 15:12 +0200, Robert Olsson wrote:

>  Haven't got all details. IMO we need to support some "bonding-like" 
>  scenario too. Where one CPU is feeding just one TX-ring. (and TX-buffers
>  cleared by same CPU). We probably don't want to stall all queuing when
>  when one ring is full. 
>  

For newer NICs - the kind of that Leonid Grossman was talking about,
makes a lot of sense in non-virtual environment.
I think the one described by Leonid has not just 8 tx/rx rings but also
a separate register set, MSI binding etc iirc. The only shared resources
as far as i understood Leonid are the bus and the ethernet wire.

So in such a case (assuming 8 rings), 
One model is creating 4 netdev devices each based on single tx/rx ring
and register set and then having a mother netdev (what you call the
bond) that feeds these children netdev based on some qos parametrization
is very sensible. Each of the children netdevices (by virtue of how we
do things today) could be tied to a CPU for effectiveness (because our
per CPU work is based on netdevs).
In virtual environments, the supervisor will be in charge of the
bond-like parent device.
Another model is creating a child netdev based on more than one ring
example 2 tx and 2 rcv rings for two netdevices etc.

>  The scenario I see is to support parallelism in forwarding/firewalling etc.
>  For example when RX load via HW gets split into different CPU's and for 
>  cache reasons we want to process in same CPU even with TX.
> 
>  If RX HW split keeps packets from the same flow on same CPU we shouldn't
>  get reordering within flows.

For the Leonid-NIC (for lack of better name) it may be harder to do
parallelization on rcv if you use what i said above. But you could
use a different model on receive - such as create a single netdev and
with 8 rcv rings and MSI tied on rcv to 8 different CPUs 
Anyways, it is an important discussion to have. ttl.

cheers,
jamal
 

