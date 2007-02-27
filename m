From: Segher Boessenkool <segher@kernel.crashing.org>
Subject: Re: [RFC] div64_64 support
Date: Tue, 27 Feb 2007 04:45:00 +0100
Message-ID: <aa5f1334222bb26e1da75694905b4314@kernel.crashing.org>
References: <20070223170527.4ca695b2@freekitty>	<Pine.LNX.4.61.0702262108010.23355@yvahk01.tjqt.qr> <20070226132834.70514f19@freekitty> <45E38762.5040407@zytor.com>
Mime-Version: 1.0 (Apple Message framework v623)
Content-Type: text/plain; charset=US-ASCII; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jan Engelhardt <jengelh@linux01.gwdg.de>, netdev@vger.kernel.org,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	linux-kernel@vger.kernel.org
To: "H. Peter Anvin" <hpa@zytor.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-in-04.arcor-online.net ([151.189.21.44]:38348 "EHLO
	mail-in-04.arcor-online.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750728AbXB0DpI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Feb 2007 22:45:08 -0500
In-Reply-To: <45E38762.5040407@zytor.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> I thought the motivation for div64() was that a 64:32->32 divide could 
> be done a lot faster on a number of platforms (including the important 
> x86) than a generic 64:64->64 divide, but gcc doesn't handle the 
> devolution automatically -- there is no such libgcc function.

That there's no such function in libgcc doesn't mean GCC
cannot handle this; libgcc is a bunch of library functions
that are really needed for generated code (because you
really don't want to expand those functions inline
everywhere) -- you won't find an addsi3 in libgcc either.

There does exist a divmoddisi4, sort of.

It used to be defined in three GCC targets, but commented
out in all three.  The NS32k is long gone.  For Vax, a
comment says the machine insn for this isn't used because
it is just too slow.  And the i386 version is disabled
because it returns the wrong result on overflow (not the
truncated 64-bit result, required by the implicit cast
to 32-bit, but the i386 arch traps to the overflow handler).

The only way to express the semantics you want in (GNU) C
is to use asm() -- and that's exactly what div64() does :-)

Blame it on the C language, but not on GCC.  Not this time.


Segher

