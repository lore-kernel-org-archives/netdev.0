From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH net-next] ebpf: Allow dereferences of PTR_TO_STACK
 registers
Date: Thu, 23 Jul 2015 14:47:03 -0700
Message-ID: <20150723214702.GA31886@Alexeis-MacBook-Pro.local>
References: <1437686680-1157510-1-git-send-email-agartrell@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, ast@kernel.org, daniel@iogearbox.net,
	netdev@vger.kernel.org, kernel-team@fb.com
To: Alex Gartrell <agartrell@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f178.google.com ([209.85.160.178]:36697 "EHLO
	mail-yk0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753863AbbGWVrH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Jul 2015 17:47:07 -0400
Received: by ykay190 with SMTP id y190so4869658yka.3
        for <netdev@vger.kernel.org>; Thu, 23 Jul 2015 14:47:06 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1437686680-1157510-1-git-send-email-agartrell@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 23, 2015 at 02:24:40PM -0700, Alex Gartrell wrote:
>         mov %rsp, %r1           ; r1 = rsp
>         add $-8, %r1            ; r1 = rsp - 8
>         store_q $123, -8(%rsp)  ; *(u64*)r1 = 123  <- valid
>         store_q $123, (%r1)     ; *(u64*)r1 = 123  <- previously invalid
>         mov $0, %r0
>         exit                    ; Always need to exit
> 
> And we'd get the following error:
> 
> 	0: (bf) r1 = r10
> 	1: (07) r1 += -8
> 	2: (7a) *(u64 *)(r10 -8) = 999
> 	3: (7a) *(u64 *)(r1 +0) = 999
> 	R1 invalid mem access 'fp'
> 
> 	Unable to load program
> 
> We already know that a register is a stack address and the appropriate
> offset, so we should be able to validate those references as well.
> 
> Signed-off-by: Alex Gartrell <agartrell@fb.com>
> ---
>  kernel/bpf/verifier.c       |  6 ++++-
>  samples/bpf/test_verifier.c | 59 +++++++++++++++++++++++++++++++++++++++++++++
>  2 files changed, 64 insertions(+), 1 deletion(-)

Looks good.
Acked-by: Alexei Starovoitov <ast@plumgrid.com>

> +			BPF_ST_MEM(BPF_DW, BPF_REG_1, 2, 0xfaceb00c),

nice constants :)
