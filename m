From: Amos Kong <jianjun@zeuux.org>
Subject: Re: [PATCH 2.6.29.1 1/1] 8139too: fix HW initial flow
Date: Mon, 20 Apr 2009 21:28:00 +0800
Message-ID: <20090420132800.GA9119@ubuntu>
References: <0E04AEADD178614A86F3017CC5FA693B4959924809@MS.vivotek.tw>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, dada1@cosmosbay.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: jon.lin@vatics.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.zeuux.org ([210.51.160.52]:58212 "EHLO z.billxu.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754211AbZDTN2W (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 20 Apr 2009 09:28:22 -0400
Content-Disposition: inline
In-Reply-To: <0E04AEADD178614A86F3017CC5FA693B4959924809@MS.vivotek.tw>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Apr 20, 2009 at 08:58:01PM +0800, jon.lin@vatics.com wrote:
>From: Jonathan Lin <jon.lin@vatics.com>
>
>While ifconfig eth0 up kernel calls open() of 8139 driver(8139too.c).
>In rtl8139_hw_start() of rtl8139_open(), 8139 driver enable RX before setting up the DMA buffer address. In this interval where RX was enabled and DMA buffer address is not yet set up, any incoming broadcast packet would be send to a strange physical address:
>0x003e8800 which is the default value of DMA buffer address.
>Unfortunately, this address is used by Linux kernel. So kernel panics.
>This patch fix it by setting up DMA buffer address before RX enabled and everything is fine even under broadcast packets attack.
>
>Signed-off-by: Jonathan Lin <jon.lin@vatics.com>

Reviewed-by: Amos Kong <jianjun@zeuux.org>

>--- linux-2.6.29.1/drivers/net/8139too.c.orig   2009-04-19 17:50:38.000000000 +0800
>+++ linux-2.6.29.1/drivers/net/8139too.c        2009-04-19 17:52:51.000000000 +0800
>@@ -1382,6 +1382,10 @@ static void rtl8139_hw_start (struct net
>        RTL_W32_F (MAC0 + 0, le32_to_cpu (*(__le32 *) (dev->dev_addr + 0)));
>        RTL_W32_F (MAC0 + 4, le16_to_cpu (*(__le16 *) (dev->dev_addr + 4)));
>
>+       tp->cur_rx = 0;
>+       /* init Rx ring buffer DMA address BEFORE Rx enabled*/
>+       RTL_W32_F (RxBuf, tp->rx_ring_dma);
>+
...
