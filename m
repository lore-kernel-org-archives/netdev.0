From: Chris Snook <csnook@redhat.com>
Subject: Re: [PATCH] Change S390 anti-dependency to CONFIG_GENERIC_HARDIRQS
 dependency
Date: Wed, 15 Oct 2008 12:48:56 -0400
Message-ID: <48F61EF8.20202@redhat.com>
References: <48F52E89.9050104@redhat.com>	<20081014.165211.53009170.davem@davemloft.net>	<48F5345B.6060108@redhat.com> <20081014.221647.184282035.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: afleming@gmail.com, afleming@freescale.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:32822 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752269AbYJOQtN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 Oct 2008 12:49:13 -0400
In-Reply-To: <20081014.221647.184282035.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Chris Snook <csnook@redhat.com>
> Date: Tue, 14 Oct 2008 20:07:55 -0400
> 
>> But then it will be much more of a pain to exclude the vast swath of
>> irrelevant code in the kernel tree from your builds on these exotic
>> architectures.  Have you ever built a kernel on s390?
> 
> That's totally irrelevant.
> 
> Does S390 have ethernet or ethernet-like devices?  If so, the someday
> it might in fact might want to use something like phylib instead of
> adding yet another implementation of programming a particular PHY
> chip.

Last I checked, s390 doesn't have any hardware that can't be shared 
between at least 64 guests.  The most Linux will ever control on that 
hardware is a software channel, be it a channel to a disk controller, 
network controller, or application-specific offload engine.  They don't 
really have NICs, more like a built-in router which can optionally fake 
layer 2 for the benefit of guests.

> So in fact, something like phylib should be possible to enable even on
> s390.
> 
> And this current situation means s390 builds get less coverage, making
> allmodconfig test builds (which the s390 folks are obviously doing
> since they hit this originally reported build failure) less
> useful than they could be.

Currently, allmodconfig on s390 is cheap, because there's a miniscule 
amount of device driver code that can be enabled in Kconfig.  If you 
enabled all those other drivers to build on s390, it would take *days* 
to complete an allmodconfig build natively or in an emulator.  Forcing 
people to use cross-compilers to get things done at a reasonable pace 
would mean treating s390 differently from other architectures in 
multi-platform build systems, and would probably have the effect that 
nobody outside of IBM would do any significant build testing on that 
architecture.

> I would even be happy to make it such that SBUS drivers can be
> enabled for test building on x86, and in fact right now in
> Linus's tree that's very close to doable.

I have no objection to that.  I have MIPS to burn on my x86 boxes.  s390 
MIPS cost a few orders of magnitude more.

-- Chris
