From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ebpf: Allow dereferences of PTR_TO_STACK
 registers
Date: Mon, 27 Jul 2015 00:54:25 -0700 (PDT)
Message-ID: <20150727.005425.1883960297878220723.davem@davemloft.net>
References: <1437686680-1157510-1-git-send-email-agartrell@fb.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ast@kernel.org, daniel@iogearbox.net, netdev@vger.kernel.org,
	kernel-team@fb.com
To: agartrell@fb.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38917 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750943AbbG0Hy3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Jul 2015 03:54:29 -0400
In-Reply-To: <1437686680-1157510-1-git-send-email-agartrell@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alex Gartrell <agartrell@fb.com>
Date: Thu, 23 Jul 2015 14:24:40 -0700

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

Applied, thanks.
