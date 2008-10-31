From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] amd811e: fix dma_free_coherent warning
Date: Fri, 31 Oct 2008 00:48:46 -0400
Message-ID: <490A8E2E.7050502@garzik.org>
References: <1225158706-5700-1-git-send-email-chunbo.luo@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: chunbo.luo@windriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:54176 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750867AbYJaEsv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 31 Oct 2008 00:48:51 -0400
In-Reply-To: <1225158706-5700-1-git-send-email-chunbo.luo@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

chunbo.luo@windriver.com wrote:
> From: Chunbo Luo <chunbo.luo@windriver.com>
> 
> Acoording commit aa24886e379d2b641c5117e178b15ce1d5d366ba,
> dma_free_coherent() need irqs enabled.
> 
> This patch fix following warning messages:
> 
> WARNING: at linux/arch/x86/kernel/pci-dma.c:376 dma_free_coherent+0xaa/0xb0()
> 
> Call Trace:
>  [<ffffffff8023f80f>] warn_on_slowpath+0x5f/0x90
>  [<ffffffff80496ffa>] ? __kfree_skb+0x3a/0xa0
>  [<ffffffff802a4723>] ? discard_slab+0x23/0x40
>  [<ffffffff8021274a>] dma_free_coherent+0xaa/0xb0
>  [<ffffffff8043668f>] amd8111e_close+0x10f/0x1b0
>  [<ffffffff8049f3ae>] dev_close+0x5e/0xb0
>  [<ffffffff8049efa1>] dev_change_flags+0xa1/0x1e0
>  [<ffffffff806b2171>] ic_close_devs+0x36/0x4e
>  [<ffffffff806b29ee>] ip_auto_config+0x581/0x10f3
>  [<ffffffff803a6e19>] ? kobject_add+0x69/0x90
>  [<ffffffff803a698a>] ? kobject_get+0x1a/0x30
>  [<ffffffff803a785b>] ? kobject_uevent+0xb/0x10
>  [<ffffffff803a6c62>] ? kset_register+0x52/0x60
>  [<ffffffff803a6f9b>] ? kset_create_and_add+0x6b/0xa0
>  [<ffffffff804e2e74>] ? tcp_ca_find+0x24/0x50
>  [<ffffffff806b246d>] ? ip_auto_config+0x0/0x10f3
>  [<ffffffff8020903c>] _stext+0x3c/0x150
>  [<ffffffff802772d3>] ? register_irq_proc+0xd3/0xf0
>  [<ffffffff802f0000>] ? mb_cache_create+0x80/0x1f0
>  [<ffffffff80688693>] kernel_init+0x141/0x1b8
>  [<ffffffff80688552>] ? kernel_init+0x0/0x1b8
>  [<ffffffff8020d609>] child_rip+0xa/0x11
>  [<ffffffff80688552>] ? kernel_init+0x0/0x1b8
>  [<ffffffff80688552>] ? kernel_init+0x0/0x1b8
>  [<ffffffff8020d5ff>] ? child_rip+0x0/0x11
> 
> Signed-off-by: Chunbo Luo <chunbo.luo@windriver.com>
> ---
>  drivers/net/amd8111e.c |    9 ++++-----
>  1 files changed, 4 insertions(+), 5 deletions(-)

applied


