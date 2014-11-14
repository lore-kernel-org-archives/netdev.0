From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net-next] fast_hash: clobber registers correctly for
 inline function use
Date: Fri, 14 Nov 2014 21:35:09 +0100
Message-ID: <1415997309.15154.59.camel@localhost>
References: <1415978022.15154.31.camel@localhost>
	 <1415979181.17262.45.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1415979978.15154.41.camel@localhost>
	 <20141114.133829.1437047454714311242.davem@davemloft.net>
	 <1415995451.15154.54.camel@localhost> <17658.1415996115@famine>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, eric.dumazet@gmail.com,
	netdev@vger.kernel.org, ogerlitz@mellanox.com, pshelar@nicira.com,
	jesse@nicira.com, discuss@openvswitch.org
To: Jay Vosburgh <jay.vosburgh@canonical.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out3-smtp.messagingengine.com ([66.111.4.27]:38423 "EHLO
	out3-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1161854AbaKNUfM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Nov 2014 15:35:12 -0500
Received: from compute1.internal (compute1.nyi.internal [10.202.2.41])
	by mailout.nyi.internal (Postfix) with ESMTP id 9A2FA2082F
	for <netdev@vger.kernel.org>; Fri, 14 Nov 2014 15:35:11 -0500 (EST)
In-Reply-To: <17658.1415996115@famine>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fr, 2014-11-14 at 12:15 -0800, Jay Vosburgh wrote:
> Hannes Frederic Sowa <hannes@stressinduktion.org> wrote:
> 
> >On Fr, 2014-11-14 at 13:38 -0500, David Miller wrote:
> >> From: Hannes Frederic Sowa <hannes@stressinduktion.org>
> >> Date: Fri, 14 Nov 2014 16:46:18 +0100
> >> 
> >> > I would still like to see the current proposed fix getting applied and
> >> > we can do this on-top. The inline call after this patch reassembles a
> >> > direct function call, so besides the long list of clobbers, it should
> >> > still be pretty fast.
> >> 
> >> I would rather revert the change entirely until it is implemented
> >> properly.
> >> 
> >> Also, I am strongly of the opinion that this is a mis-use of the
> >> alternative call interface.  It was never intended to be used for
> >> things that can make real function calls.
> >
> >I tend to disagree. Grepping e.g. shows
> >
> >        alternative_call_2(copy_user_generic_unrolled,
> >                         copy_user_generic_string,
> >                         X86_FEATURE_REP_GOOD,
> >                         copy_user_enhanced_fast_string,
> >                         X86_FEATURE_ERMS,
> >                         ASM_OUTPUT2("=a" (ret), "=D" (to), "=S" (from),
> >                                     "=d" (len)),
> >                         "1" (to), "2" (from), "3" (len)
> >                         : "memory", "rcx", "r8", "r9", "r10", "r11");
> >
> >
> >(it has a few less clobbers because it has more output operands)
> 
> 	As those functions (copy_user_generic_unrolled, et al) are all
> in assembly language, presumably the list of clobbered registers can be
> had via inspection.
> 
> 	For the arch_fast_hash2 case, the functions (__intel_crc4_2_hash
> and __jash2) are both written in C, so how would the clobber list be
> created?

I created it via the function calling convention documented in
arch/x86/include/asm/calling.h, so I specified each register which a
function is allowed to clobber with.

I currently cannot see how I can resolve the invalid constraints error
easily. :(

So either go with my first patch, which I puts the alternative_call
switch point into its own function without ever inlining or the patch
needs to be reverted. :/

Bye,
Hannes
