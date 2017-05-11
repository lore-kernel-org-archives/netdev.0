From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/5] bpf: Track alignment of register values in the
 verifier.
Date: Thu, 11 May 2017 10:49:04 -0400 (EDT)
Message-ID: <20170511.104904.2085723000669887052.davem@davemloft.net>
References: <20170510.150942.1969073633182798014.davem@davemloft.net>
        <59145BEC.9040804@iogearbox.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ast@fb.com, alexei.starovoitov@gmail.com, netdev@vger.kernel.org
To: daniel@iogearbox.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:50780 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932984AbdEKOtQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 11 May 2017 10:49:16 -0400
In-Reply-To: <59145BEC.9040804@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <daniel@iogearbox.net>
Date: Thu, 11 May 2017 14:41:16 +0200

> On 05/10/2017 09:09 PM, David Miller wrote:
>>
>> Currently if we add only constant values to pointers we can fully
>> validate the alignment, and properly check if we need to reject the
>> program on CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS architectures.
> 
> Should say: !CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS

Ok.

>>
>> The existing code will reject the load of th->dport because it cannot
> 
> s/th->dport/th->dest/

Right :)

> In adjust_reg_min_max_vals(), don't we also need to call
> reset_reg_align() in the 'default' case for the cases where
> we use have ALU ops that we don't bother tracking (mod, div,
> endianess ops, etc)?
> 
> Likewise, for other cases where we do reset_reg_range_values()
> which is BPF_LD as class and for the BPF_MOV in check_alu_op(),
> which I think, is only relevant when we move reg A to reg B
> in 32 bit mode. Perhaps it makes sense to consolidate the reset
> on alignment with the reset of min/max values, or do we have
> cases where this is undesirable (not that I'm currently aware
> of ...)?

I can't think of any situation where these two actions don't have
to both be performned, so I've moved the alignment clear into
reset_reg_range_values() and removed reset_reg_align() altogether.

> But other than that:
> 
> Acked-by: Daniel Borkmann <daniel@iogearbox.net>

Thanks for reviewing.
