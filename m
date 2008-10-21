From: Steve.Glendinning@smsc.com
Subject: Re: [PATCH 14/16] RealView: Use the in-kernel smc911x.c driver on	RealView
Date: Tue, 21 Oct 2008 11:26:42 +0100
Message-ID: <OF6B543A5F.032D7BBC-ON802574E9.00340E58-802574E9.00396C6E@smsc.com>
References: <1224578293.9330.9.camel@pc1117.cambridge.arm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: Bill Gatliff <bgat@billgatliff.com>,
	Guennadi Liakhovetski <g.liakhovetski@gmx.de>,
	linux-arm-kernel@lists.arm.linux.org.uk, Ian.Saturley@smsc.com,
	netdev@vger.kernel.org
To: Catalin Marinas <catalin.marinas@arm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.smsc.com ([170.129.50.11]:2094 "EHLO smsc.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750718AbYJUK1l (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 21 Oct 2008 06:27:41 -0400
In-Reply-To: <1224578293.9330.9.camel@pc1117.cambridge.arm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,

> > Of course, this is even more interesting given that there's a new, 
smsc911x
> > driver floating around on netdev that's supposed to replace the 
> existing one.
> > 
> > It's submitted by SMSC themselves, and has the support of the 
> smc911x author too...
> 
> I think that's been going on for more than a year. We used (and
> contributed to) the new driver in ARM Ltd from the early stages and we
> are happy with it. However, I'd like the mainline kernel to have a
> working configuration for the RealView boards without additional patches
> (we'll probably still use the new driver for our stable, mostly internal
> kernel releases).

The smsc911x driver is still maintained (out of tree), and is used by many
of our customers.  Mainline inclusion is still very much the intention!

Almost all the feedback I've had has been positive, but I've had a few
"can't you just fix the in-tree driver?" responses.  The trouble is it's
not a *small* piece of work!

Both drivers have their technical advantages:

smsc911x
- uses functions instead of macros, making it more readable
- uses napi (and manages significantly higher throughput because of it)
- uses phylib
- passes checkpatch.pl
- has workarounds for older LAN911x variants

smc911x
- is already in-tree (not really technical, but still important)
- has support for pxa dma*
- has dynamic bus width config

We could start from either driver to incorporate the extra features of
the other, but I think it would be significantly less work to start from
smsc911x.  What does everyone else think?

* I do have a patch to add DMA support to smsc911x, but it's
platform-specific to sh.  I haven't added pxa dma support only because I
don't have a suitable pxa platform available.

> Regarding the merging of the new driver, the last version posted was in
> June 2008 and the author stated that he's now focusing on the LAN9500
> USB Ethernet driver before re-posting the LAN911x one:
> 
> http://marc.info/?l=linux-netdev&m=122097407603180&w=2

The LAN9500 driver is in-tree now, so I'll be updating smsc911x for 
changes
in current git and reposting for review later today.

Regards,
--
Steve Glendinning
SMSC GmbH
m: +44 777 933 9124
e: steve.glendinning@smsc.com


