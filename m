From: jason.morgan@aveillant.com
Subject: Re: tx checksum offload in rtl8168evl disabled in driver
Date: Tue, 8 Oct 2013 19:44:46 +0100
Message-ID: <OFF8B96673.6A7E8713-ON80257BFE.0064D5B6-80257BFE.0066FC7A@aveillant.com>
References: <OF3E5567E2.6AC62D58-ON80257BF9.004ED219-80257BF9.004F713D@aveillant.com> <20131003230120.GA25047@electric-eye.fr.zoreil.com> <OF48469889.D817DB84-ON80257BFA.0032A86F-80257BFA.0032E20E@aveillant.com> <20131005092252.GA23084@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: Hayes Wang <hayeswang@realtek.com>, netdev@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from outbound-240.asp.reflexion.net ([69.84.129.240]:65027 "EHLO
	asp.reflexion.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751686Ab3JHSpD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Oct 2013 14:45:03 -0400
In-Reply-To: <20131005092252.GA23084@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> 
> (please don't top post)

Sorry, I was not aware of the correct netiquette
replies now inline.

> 
> jason.morgan@....> :
> > Ubuntu 12.04.3 LTS + Kernel 3.8.13-8 64bit
> > 
> > I've patched the driver to allow tx checksum offload for this chip and
> > found the following:
> >
> > MTU 9000 standard driver:
> > 517Mbps with 2k + header frames
> > 
> > MTU 9000 patched driver:
> > 770Mbps with 2k + header frames
> > 
> > 100% transfer without error (1e6 frames)
> 
> (Ok, so that's 20 ~ 30s worth of traffic)

Right now this is representative as the network has no other traffic and 
the CPU has no other function.
I will be producing hours of traffic soon in a more realistic network, see 
later....

> 
> > 48% increase in performance combined with a massive decrease in CPU
> > effort is not to be sniffed at.
> 
> *sniff* :o)

Drums.... BurrDumpf!

> 
> It depends on the CPU. You did not specify it and you did not give 
numbers
> for the decrease (did you use 'perf' btw ?). They would be welcome.

As I've patched the kernel driver and build a new kernel, I have no idea 
how to build a perf for my installed kernel.
It appears that there is not one pre-built.
Any help here?
When I learn how to build perf I can reply with CPU performance data.

> 
> > IMO tx offload should be more prevalent as the frames grow, to reduce 
> > CPU load.
> 
> I can't disagree.
> 
> > OK, so make the default OFF if there is a silicon error (that spans
> > mulitple chips?),
> 
> Yes, I want safe defaults for the kernel.

Safe defaults are of course a good thing.

Others have stated that this is not a silicon error, it's a hardware 
feature which it appears
the Linux default for which is non-optimal and there is no means (bar 
hacking) to optimise it.

> 
> I give the manufacturer's explanations a lot of credit when they're
> related to hardware (up to the point where the marketing or legal dept
> kicks in). If we want to balance these with experimental evidences, the
> latter must be really, really strong.

To me it appears the latency stats ( a marketing metric of the MAC ) 
somehow outweigh the load on the CPU
( which is factored out of MAC stats ) so perhaps your comment on the 
marketing dept rings true?

Are there any tests that you can suggest that would provide such evidence?

I am in the process of building a LAN of 18 machines with the intent of
saturating a 1G/10G Ethernet switch, so I have a good test platform - for 
one chip anyway.

> 
> > but why prevent it being turned on in the driver? 
> > even if there is a kernel message that this might cause problems.
> 
> Two points:
> - it's a hack: ethtool will return success. A kernel message is not a
> substitute for "Yes, I opt in for problems".
> - we can't tell when it's safe and when it isn't.

I would agree that generally ethtool can't be trusted, but it is clear 
that
it does work with this driver for this chip for this control so in that 
case surely it can be trusted?

The statement "we can't tell when it's safe and when it isn't." is true 
for almost any hardware interface
Usually we offer safe defaults and a means to trade off safety and 
performance, though that is not always the case, e.g.
It's much safer to run DDR3-1600 as DDR3-1066, but if that were the 
default people would complain.

> 
> -- 
> Ueimor
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at http://vger.kernel.org/majordomo-info.html
