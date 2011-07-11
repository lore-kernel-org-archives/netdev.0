From: Matt Evans <matt@ozlabs.org>
Subject: Re: [RFC PATCH 1/1] BPF JIT for PPC64
Date: Mon, 11 Jul 2011 16:27:27 +1000
Message-ID: <4E1A97CF.80509@ozlabs.org>
References: <4E04288F.4090201@ozlabs.org> <m2boxmxt45.fsf@igel.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	linuxppc-dev <linuxppc-dev@lists.ozlabs.org>
To: Andreas Schwab <schwab@linux-m68k.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:37458 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756236Ab1GKG1I (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Jul 2011 02:27:08 -0400
In-Reply-To: <m2boxmxt45.fsf@igel.home>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 25/06/11 17:33, Andreas Schwab wrote:
> Matt Evans <matt@ozlabs.org> writes:
> 
>> +	stdu	r1, -128(r1);					\
> 
>> +	addi	r5, r1, 128+BPF_PPC_STACK_BASIC+(2*8);		\
> 
>> +	addi	r1, r1, 128;					\
> 
>> +					PPC_STD(r_M + i, 1, -128 + (8*i));
> 
>> +					PPC_LD(r_M + i, 1, -128 + (8*i));
> 
> s/128/BPF_PPC_STACK_SAVE/?

Actually, that's a different 128, but that nicely illustrates that I should've
#defined something more recognisable :-) The second set, with -128, is actually
in the save area for non-volatile regs, whereas the first is just a stackframe
size.

Cheers,


Matt
