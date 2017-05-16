From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 1/3] bpf: Use 1<<16 as ceiling for immediate
 alignment in verifier.
Date: Tue, 16 May 2017 15:52:11 -0400 (EDT)
Message-ID: <20170516.155211.2029345941344452552.davem@davemloft.net>
References: <20170515.120431.1588221938554447723.davem@davemloft.net>
        <754f2c39-fdb0-2407-c2f2-aa36d506d202@solarflare.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: daniel@iogearbox.net, ast@fb.com, alexei.starovoitov@gmail.com,
        netdev@vger.kernel.org
To: ecree@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:53028 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750885AbdEPTwN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 16 May 2017 15:52:13 -0400
In-Reply-To: <754f2c39-fdb0-2407-c2f2-aa36d506d202@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Edward Cree <ecree@solarflare.com>
Date: Tue, 16 May 2017 13:37:42 +0100

> On 15/05/17 17:04, David Miller wrote:
>> If we use 1<<31, then sequences like:
>>
>> 	R1 = 0
>> 	R1 <<= 2
>>
>> do silly things.
> Hmm.  It might be a bit late for this, but I wonder if, instead of handling
>  alignments as (1 << align), you could store them as -(1 << align), i.e.
>  leading 1s followed by 'align' 0s.
> Now the alignment of 0 is 0 (really 1 << 32), which doesn't change when
>  left-shifted some more.  Shifts of other numbers' alignments also do the
>  right thing, e.g. align(6) << 2 = (-2) << 2 = -8 = align(6 << 2).  Of
>  course you do all this in unsigned, to make sure right shifts work.
> This also makes other arithmetic simple to track; for instance, align(a + b)
>  is at worst align(a) | align(b).  (Of course, this bound isn't tight.)
> A number is 2^(n+1)-aligned if the 2^n bit of its alignment is cleared.
> Considered as unsigned numbers, smaller values are stricter alignments.

Thanks for the bit twiddling suggestion, I'll take a look!
