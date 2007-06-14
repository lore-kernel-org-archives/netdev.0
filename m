From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH] NET: Multiqueue network device support.
Date: Thu, 14 Jun 2007 07:48:27 -0400
Message-ID: <1181821707.4091.32.camel@localhost>
References: <466DEF9D.9070509@trash.net>
	 <1181615384.4071.121.camel@localhost>	<466E9DF2.9010505@trash.net>
	 <20070612.140240.00078635.davem@davemloft.net> <466F0D74.5030308@trash.net>
	 <1181714168.4758.57.camel@debian.sh.intel.com>
	 <1181737935.4050.87.camel@localhost>
	 <1181789064.4758.127.camel@debian.sh.intel.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>,
	David Miller <davem@davemloft.net>,
	peter.p.waskiewicz.jr@intel.com, netdev@vger.kernel.org,
	jeff@garzik.org, auke-jan.h.kok@intel.com
To: Zhu Yi <yi.zhu@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from py-out-1112.google.com ([64.233.166.176]:27931 "EHLO
	py-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751023AbXFNLsb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Jun 2007 07:48:31 -0400
Received: by py-out-1112.google.com with SMTP id a29so889606pyi
        for <netdev@vger.kernel.org>; Thu, 14 Jun 2007 04:48:30 -0700 (PDT)
In-Reply-To: <1181789064.4758.127.camel@debian.sh.intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Yi,

On Thu, 2007-14-06 at 10:44 +0800, Zhu Yi wrote:
> On Wed, 2007-06-13 at 08:32 -0400, jamal wrote:
> > The key arguement i make (from day one actually) is to leave the
> > majority of the work to the driver.
> 
> But it seems not feasible the Qdisc needs to know nothing about the
> hardware rings.

This discussion is addressing whether it is feasible to do it without
the qdisc knowing anything about the hardware ring.

> > My view of wireless WMM etc is it is a different media behavior
> > (compared to wired ethernet) which means a different view of strategy
> > for when it opens the valve to allow in more packets. 802.11 media has
> > embedded signalling which is usable. Guy Cohen gave a good use case
> > which i responded to. Do you wanna look at that and respond? 
> 
> The key to support multi-ring hardware for software is to put packets
> into hardware as much/early as possible. Guy gave a good VO vs. BK
> example. To achieve this in your model, you have to keep the TX ring
> running (in the case of PHL full) and requeue. But when there are only
> BK packets coming, you do want to stop the ring, right? AFAICS, the
> driver is not the best place to make the decision (it only knows the
> current and previous packets, but not the _next_), the Qdisc is the best
> place.
> 

I dont have much time to followup for sometime to come. I have left my
answer above. To clarify, incase i wasnt clear, I am saying:
a) It is better to have the driver change via some strategy of when to
open the tx path than trying to be generic. This shifts the burden to
the driver.
b) given the behavior of wireless media (which is very different from
wired ethernet media), you need a different strategy. In response to
Guy's question, I gave the example of being able to use management
frames to open up the tx path for VO (even when you dont know VO packets
are sitting on the qdisc); alternatively you could use a timer etc.
Theres many ways to skin the cat (with apologies to cat lovers/owners).
i.e you need to look at the media and be creative.
Peters DCE for example could also be handled by having a specific
strategy.

I will try to continue participating in the discussion (if CCed) but
much less for about a week. In any case I think i have had the
discussion i was hoping for and trust Patrick understands both sides.
This thread has run for too long folks, eh?

cheers,
jamal

