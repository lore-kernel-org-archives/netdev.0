From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: [PATCH,RFC] Re: r8169 driver problem with RTL8110SB chip (on iop3xx ARM board)
Date: Tue, 5 Sep 2006 00:27:15 +0200
Message-ID: <20060904222715.GF3782@xi.wantstofly.org>
References: <20060728101109.GA25854@xi.wantstofly.org> <20060818212852.GA5379@xi.wantstofly.org> <20060820213558.GA13188@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, tbm@cyrius.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from alephnull.demon.nl ([83.160.184.112]:59529 "EHLO
	xi.wantstofly.org") by vger.kernel.org with ESMTP id S965019AbWIDW1T
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Sep 2006 18:27:19 -0400
To: Francois Romieu <romieu@fr.zoreil.com>
Content-Disposition: inline
In-Reply-To: <20060820213558.GA13188@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Aug 20, 2006 at 11:35:58PM +0200, Francois Romieu wrote:

> > 2. SYSErr asserts pretty soon after upping eth0, and the PCI status
> >    register reports a parity error when this happens.  In this case,
> >    the restart logic seems to make things worse, and in fact, when
> >    commenting it out, things work a lot better.
> 
> [snip]
> 
> 2 - I have already experienced SYSErr storms on startup. If memory serves me
>     right, they were "cured" simply by disabling a bit in the irq mask
>     (not sure if it was SYSErr, RxOverflow or RxFIFOOver though).
> 
> Can you try against -rc4:
> 1) the serie at http://www.fr.zoreil.com/linux/kernel/2.6.x/2.6.18-rc4/r8169
>    There is a minor difference in the init of Realtek's driver for the 8110sb
>    (patch 011). It could hurt different chipset but it should do no harm to
>    the 8110sb.
> 2) same as 1) + your hunk below:
> @@ -484,7 +488,7 @@ static int rtl8169_poll(struct net_devic
>  #endif
>  
>  static const u16 rtl8169_intr_mask =
> -	SYSErr | LinkChg | RxOverflow | RxFIFOOver | TxErr | TxOK | RxErr | RxOK;
> +	LinkChg | RxOverflow | RxFIFOOver | TxErr | TxOK | RxErr | RxOK;
>  static const u16 rtl8169_napi_event =
>  	RxOK | RxOverflow | RxFIFOOver | TxOK | TxErr;
>  static const unsigned int rtl8169_rx_config =
> 3) same as 2) + your TxDesc change.

I tried your series from step (1) plus my TxDesc change (so I didn't
include the hunk from (2)), and that seems to work fine.  I.e. I don't
need to disable error interrupts anymore to keep it working.

So really the only thing that would need addressing would be the TXDesc
MMIO bug (either by using I/O accesses, or doing the top/bottom writes
the other way round) and we can dump the vendor driver.

Thanks a lot!


cheers,
Lennert
