From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH RESEND] bnx2x: fix crash during TSO tunneling
Date: Thu, 24 Jul 2014 18:37:54 +0200
Message-ID: <1406219874.3363.71.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1406217287-4069-1-git-send-email-Dmitry.Kravkov@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, ypei@redhat.com,
	mschmidt@redhat.com, Dmitry Kravkov <Dmitry.Kravkov@qlogic.com>
To: Dmitry Kravkov <dkravkov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f43.google.com ([74.125.82.43]:42973 "EHLO
	mail-wg0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759448AbaGXQiQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Jul 2014 12:38:16 -0400
Received: by mail-wg0-f43.google.com with SMTP id l18so2903428wgh.2
        for <netdev@vger.kernel.org>; Thu, 24 Jul 2014 09:38:14 -0700 (PDT)
In-Reply-To: <1406217287-4069-1-git-send-email-Dmitry.Kravkov@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2014-07-24 at 18:54 +0300, Dmitry Kravkov wrote:
> From: Dmitry Kravkov <Dmitry.Kravkov@qlogic.com>
> 
> When TSO packet is transmitted additional BD w/o mapping is used
> to describe the packed. The BD needs special handling in tx
> completion.
> 
> kernel: Call Trace:
> kernel: <IRQ>  [<ffffffff815e19ba>] dump_stack+0x19/0x1b
> kernel: [<ffffffff8105dee1>] warn_slowpath_common+0x61/0x80
> kernel: [<ffffffff8105df5c>] warn_slowpath_fmt+0x5c/0x80
> kernel: [<ffffffff814a8c0d>] ? find_iova+0x4d/0x90
> kernel: [<ffffffff814ab0e2>] intel_unmap_page.part.36+0x142/0x160
> kernel: [<ffffffff814ad0e6>] intel_unmap_page+0x26/0x30
> kernel: [<ffffffffa01f55d7>] bnx2x_free_tx_pkt+0x157/0x2b0 [bnx2x]
> kernel: [<ffffffffa01f8dac>] bnx2x_tx_int+0xac/0x220 [bnx2x]
> kernel: [<ffffffff8101a0d9>] ? read_tsc+0x9/0x20
> kernel: [<ffffffffa01f8fdb>] bnx2x_poll+0xbb/0x3c0 [bnx2x]
> kernel: [<ffffffff814d041a>] net_rx_action+0x15a/0x250
> kernel: [<ffffffff81067047>] __do_softirq+0xf7/0x290
> kernel: [<ffffffff815f3a5c>] call_softirq+0x1c/0x30
> kernel: [<ffffffff81014d25>] do_softirq+0x55/0x90
> kernel: [<ffffffff810673e5>] irq_exit+0x115/0x120
> kernel: [<ffffffff815f4358>] do_IRQ+0x58/0xf0
> kernel: [<ffffffff815e94ad>] common_interrupt+0x6d/0x6d
> kernel: <EOI>  [<ffffffff810bbff7>] ? clockevents_notify+0x127/0x140
> kernel: [<ffffffff814834df>] ? cpuidle_enter_state+0x4f/0xc0
> kernel: [<ffffffff81483615>] cpuidle_idle_call+0xc5/0x200
> kernel: [<ffffffff8101bc7e>] arch_cpu_idle+0xe/0x30
> kernel: [<ffffffff810b4725>] cpu_startup_entry+0xf5/0x290
> kernel: [<ffffffff815cfee1>] start_secondary+0x265/0x27b
> kernel: ---[ end trace 11aa7726f18d7e80 ]---
> 
> Reported-by: Yulong Pei <ypei@redhat.com>
> Cc: Michal Schmidt <mschmidt@redhat.com>
> Signed-off-by: Dmitry Kravkov <Dmitry.Kravkov@qlogic.com>
> ---

How old is this bug ? Can you point original commit adding it ?

Thanks !
