From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH net-next v3 1/3] net: filter: simplify label names from
 jump-table
Date: Thu, 01 May 2014 19:39:49 +0200
Message-ID: <536286E5.1080309@redhat.com>
References: <1398960996-10469-1-git-send-email-dborkman@redhat.com>  <1398960996-10469-2-git-send-email-dborkman@redhat.com> <1398964810.29914.200.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, ast@plumgrid.com, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:59546 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751464AbaEARj6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 1 May 2014 13:39:58 -0400
In-Reply-To: <1398964810.29914.200.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/01/2014 07:20 PM, Eric Dumazet wrote:
> On Thu, 2014-05-01 at 18:16 +0200, Daniel Borkmann wrote:
>> This patch simplifies label naming for the BPF jump-table.
>> When we define labels via DL(), we just concatenate/textify
>> the combination of instruction opcode which consists of the
>> class, subclass, word size, target register and so on. Each
>> time we leave BPF_ prefix intact, so that e.g. the preprocessor
>> generates a label BPF_ALU_BPF_ADD_BPF_X for DL(BPF_ALU, BPF_ADD,
>> BPF_X) whereas a label name of ALU_ADD_X is much more easy
>> to grasp. Pure cleanup only.
>>
>> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
>> Acked-by: Alexei Starovoitov <ast@plumgrid.com>
>> ---
>
> This exactly makes harder to use grep and future code reviews.
>
> # git grep -n BPF_XADD
> include/linux/filter.h:21:#define BPF_XADD      0xc0    /* exclusive add */
> net/core/filter.c:224:          DL(BPF_STX, BPF_XADD, BPF_W),
> net/core/filter.c:225:          DL(BPF_STX, BPF_XADD, BPF_DW),
> net/core/filter.c:481:  BPF_STX_BPF_XADD_BPF_W: /* lock xadd *(u32 *)(A + insn->off) += X */
> net/core/filter.c:485:  BPF_STX_BPF_XADD_BPF_DW: /* lock xadd *(u64 *)(A + insn->off) += X */
>
> Compare now with :
>
> # git grep -n XADD
>
> So I am quite against this patch.

Well, if you review the code itself in filter.c it makes it hard
to read and review, with this patch, you'll immediately get the
label name and what it actually does, so I think it's quite convenient
and way more readable by itself. For grepping, you can always add
subdirectories you're searching for, besides that I don't think
that everything in the kernel needs to have unique names only so
that one can grep for it among the whole tree.
