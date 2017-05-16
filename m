From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/3] bpf: Track alignment of MAP pointers in verifier.
Date: Tue, 16 May 2017 15:08:42 -0400 (EDT)
Message-ID: <20170516.150842.1909732065431538554.davem@davemloft.net>
References: <5919A8AA.9010401@iogearbox.net>
        <20170515.113419.1265777991542814689.davem@davemloft.net>
        <591A23E3.2050105@iogearbox.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ast@fb.com, alexei.starovoitov@gmail.com, netdev@vger.kernel.org
To: daniel@iogearbox.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:52556 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751649AbdEPTIo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 16 May 2017 15:08:44 -0400
In-Reply-To: <591A23E3.2050105@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <daniel@iogearbox.net>
Date: Mon, 15 May 2017 23:55:47 +0200

> I'm actually wondering about the min_align/aux_off/aux_off_align and
> given this is not really related to varlen_map_access and we currently
> just skip this.
> 
> We should make sure that when env->strict_alignment is false that we
> ignore any difference in min_align/aux_off/aux_off_align, afaik, the
> min_align would also be set on regs other than ptr_to_pkt.

Ok I see what you are saying, alignment related register state has to
be taken into consideration during pruning but only when
env->strict_alignment is true.

->min_align is set on any register upon which a calculation is
performed.

> What about compare_ptrs_to_packet() for when env->strict_alignment is
> true in ptr_to_pkt case?

Yes we need to do something there, and yes we do need testcases.

You also remind me that I was thinking about whether we should
propagate alignment state through branches.  For example on
the taken path of a JEQ we can set both arms of the test to
have the largest of the two arms alignment.
