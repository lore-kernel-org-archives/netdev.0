From: OGAWA Hirofumi <hirofumi@mail.parknet.co.jp>
Subject: Re: [RFT] merged 8139too NAPI
Date: Tue, 21 Oct 2003 22:35:11 +0900
Sender: netdev-bounce@oss.sgi.com
Message-ID: <877k2ysohc.fsf@devron.myhome.or.jp>
References: <3F9070B6.9090306@pobox.com> <873cdqbt6z.fsf@devron.myhome.or.jp>
	<20031020131106.6862e951.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jgarzik@pobox.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20031020131106.6862e951.shemminger@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Stephen Hemminger <shemminger@osdl.org> writes:

> +	spin_lock_bh(&tp->rx_lock);
>  	/* disable Tx ASAP, if not already */
>  	tmp8 = RTL_R8 (ChipCmd);
>  	if (tmp8 & CmdTxEnb)
> @@ -1679,6 +1682,7 @@
>  
>  	/* ...and finally, reset everything */
>  	rtl8139_hw_start (dev);
> +	spin_unlock_bh(&tp->rx_lock);

->tx_timeout is on timer softirq context. So softirq was disabled already.
Or Is this for future changes?

> +	/* Check uncommon events with one test. */
> +	if (unlikely(status & (PCIErr | PCSTimeout | RxUnderrun | RxOverflow)))
> +		rtl8139_weird_interrupt (dev, tp, ioaddr,
> +					 status, link_changed);

I couldn't find this on previous email, rtl8139_weird_interrupt was changing. 

	if (unlikely(status & (PCIErr|PCSTimeout|RxUnderrun|RxErr|RxFIFOOver)))
		rtl8139_weird_interrupt(dev, tp, ioaddr, status, link_changed);

It should check the above status.
-- 
OGAWA Hirofumi <hirofumi@mail.parknet.co.jp>
