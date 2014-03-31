From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: NFS does not work on linux-next 20140331
Date: Mon, 31 Mar 2014 18:21:20 +0200
Message-ID: <20140331162120.GA10752@order.stressinduktion.org>
References: <CAOMZO5DQ3dNB-R5rsd2X89XLbg_VYs7za8xQT2K-bWWmFS=YHA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
To: Fabio Estevam <festevam@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:42338 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753424AbaCaQVW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Mar 2014 12:21:22 -0400
Content-Disposition: inline
In-Reply-To: <CAOMZO5DQ3dNB-R5rsd2X89XLbg_VYs7za8xQT2K-bWWmFS=YHA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 31, 2014 at 01:14:56PM -0300, Fabio Estevam wrote:
> Hi,
> 
> When running linux-next 20140331 I am no longer able to mount NFS on a
> mx6qsabresd board:
> 
> =================================
> [ INFO: inconsistent lock state ]
> 3.14.0-rc8-next-20140331 #964 Not tainted
> ---------------------------------
> inconsistent {IN-SOFTIRQ-W} -> {SOFTIRQ-ON-W} usage.
> kworker/0:2/50 [HC0[0]:SC0[0]:HE1:SE1] takes:
>  (&addrconf_stats->syncp.seq){+.?...}, at: [<8057ca88>] mld_send_initial_cr.par0
> {IN-SOFTIRQ-W} state was registered at:
>   [<8006366c>] mark_lock+0x140/0x6ac
>   [<80063ebc>] __lock_acquire+0x2e4/0x1c00
>   [<80065cbc>] lock_acquire+0x68/0x7c
>   [<8057bf28>] mld_sendpack+0xec/0x73c
>   [<8057cc80>] mld_ifc_timer_expire+0x1e4/0x2e4
>   [<8003310c>] call_timer_fn+0x74/0xec
>   [<80033a5c>] run_timer_softirq+0x1c4/0x264
>   [<8002d3d4>] __do_softirq+0x130/0x278
>   [<8002d814>] irq_exit+0xb0/0x104
>   [<8000f47c>] handle_IRQ+0x58/0xb8
>   [<80008680>] gic_handle_irq+0x30/0x64
>   [<800129a4>] __irq_svc+0x44/0x5c
>   [<8005f9dc>] cpu_startup_entry+0xfc/0x160
>   [<80617a3c>] rest_init+0xb0/0xd8
>   [<8083db58>] start_kernel+0x324/0x388
>   [<10008074>] 0x10008074
> irq event stamp: 62347
> hardirqs last  enabled at (62347): [<8002d67c>] __local_bh_enable_ip+0x80/0xe8
> hardirqs last disabled at (62345): [<8002d63c>] __local_bh_enable_ip+0x40/0xe8
> softirqs last  enabled at (62346): [<80558740>] ip6_finish_output2+0x16c/0x9d8
> softirqs last disabled at (62334): [<80558624>] ip6_finish_output2+0x50/0x9d8
> 
> other info that might help us debug this:
>  Possible unsafe locking scenario:
> 
>        CPU0
>        ----
>   lock(&addrconf_stats->syncp.seq);
>   <Interrupt>
>     lock(&addrconf_stats->syncp.seq);

Shit, my fault, statistic counters again. Hasn't turned up in my
testing. I cook a patch today.

Thanks,

  Hannes
