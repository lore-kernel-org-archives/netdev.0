From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next v3 1/3] net: filter: simplify label names from
 jump-table
Date: Thu, 01 May 2014 10:20:10 -0700
Message-ID: <1398964810.29914.200.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1398960996-10469-1-git-send-email-dborkman@redhat.com>
	 <1398960996-10469-2-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, ast@plumgrid.com, netdev@vger.kernel.org
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:41156 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751212AbaEARUM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 May 2014 13:20:12 -0400
Received: by mail-pa0-f52.google.com with SMTP id kx10so3953901pab.25
        for <netdev@vger.kernel.org>; Thu, 01 May 2014 10:20:11 -0700 (PDT)
In-Reply-To: <1398960996-10469-2-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2014-05-01 at 18:16 +0200, Daniel Borkmann wrote:
> This patch simplifies label naming for the BPF jump-table.
> When we define labels via DL(), we just concatenate/textify
> the combination of instruction opcode which consists of the
> class, subclass, word size, target register and so on. Each
> time we leave BPF_ prefix intact, so that e.g. the preprocessor
> generates a label BPF_ALU_BPF_ADD_BPF_X for DL(BPF_ALU, BPF_ADD,
> BPF_X) whereas a label name of ALU_ADD_X is much more easy
> to grasp. Pure cleanup only.
> 
> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
> Acked-by: Alexei Starovoitov <ast@plumgrid.com>
> ---

This exactly makes harder to use grep and future code reviews.

# git grep -n BPF_XADD
include/linux/filter.h:21:#define BPF_XADD      0xc0    /* exclusive add */
net/core/filter.c:224:          DL(BPF_STX, BPF_XADD, BPF_W),
net/core/filter.c:225:          DL(BPF_STX, BPF_XADD, BPF_DW),
net/core/filter.c:481:  BPF_STX_BPF_XADD_BPF_W: /* lock xadd *(u32 *)(A + insn->off) += X */
net/core/filter.c:485:  BPF_STX_BPF_XADD_BPF_DW: /* lock xadd *(u64 *)(A + insn->off) += X */

Compare now with :

# git grep -n XADD

So I am quite against this patch.
