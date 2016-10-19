From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] bpf: Detect identical
 PTR_TO_MAP_VALUE_OR_NULL registers
Date: Wed, 19 Oct 2016 11:09:42 -0400 (EDT)
Message-ID: <20161019.110942.1093696611535286858.davem@davemloft.net>
References: <c678e43377187d72c87a030ad27afbcd7748e1e3.1476812715.git.tgraf@suug.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, alexei.starovoitov@gmail.com,
        daniel@iogearbox.net, jbacik@fb.com
To: tgraf@suug.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:56508 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752745AbcJSPJo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 19 Oct 2016 11:09:44 -0400
In-Reply-To: <c678e43377187d72c87a030ad27afbcd7748e1e3.1476812715.git.tgraf@suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Graf <tgraf@suug.ch>
Date: Tue, 18 Oct 2016 19:51:19 +0200

> A BPF program is required to check the return register of a
> map_elem_lookup() call before accessing memory. The verifier keeps
> track of this by converting the type of the result register from
> PTR_TO_MAP_VALUE_OR_NULL to PTR_TO_MAP_VALUE after a conditional
> jump ensures safety. This check is currently exclusively performed
> for the result register 0.
> 
> In the event the compiler reorders instructions, BPF_MOV64_REG
> instructions may be moved before the conditional jump which causes
> them to keep their type PTR_TO_MAP_VALUE_OR_NULL to which the
> verifier objects when the register is accessed:
> 
> 0: (b7) r1 = 10
> 1: (7b) *(u64 *)(r10 -8) = r1
> 2: (bf) r2 = r10
> 3: (07) r2 += -8
> 4: (18) r1 = 0x59c00000
> 6: (85) call 1
> 7: (bf) r4 = r0
> 8: (15) if r0 == 0x0 goto pc+1
>  R0=map_value(ks=8,vs=8) R4=map_value_or_null(ks=8,vs=8) R10=fp
> 9: (7a) *(u64 *)(r4 +0) = 0
> R4 invalid mem access 'map_value_or_null'
> 
> This commit extends the verifier to keep track of all identical
> PTR_TO_MAP_VALUE_OR_NULL registers after a map_elem_lookup() by
> assigning them an ID and then marking them all when the conditional
> jump is observed.
> 
> Signed-off-by: Thomas Graf <tgraf@suug.ch>
> Reviewed-by: Josef Bacik <jbacik@fb.com>
> Acked-by: Daniel Borkmann <daniel@iogearbox.net>
> Acked-by: Alexei Starovoitov <ast@kernel.org>

Applied, thanks Thomas.
