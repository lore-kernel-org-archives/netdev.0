From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH] stmmac: extend DMA initialization delay to 2.5 seconds
Date: Thu, 05 Jun 2014 15:24:59 -0700 (PDT)
Message-ID: <20140605.152459.1082790961637060914.davem@davemloft.net>
References: <1401973080-10085-1-git-send-email-abrodkin@synopsys.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, hdegoede-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
	peppe.cavallaro-qxv4g6HH51o@public.gmane.org, wens-jdAy2FN1RRM@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Vineet.Gupta1-HKixBCOQz3hWk0Htik3J/w@public.gmane.org
To: Alexey.Brodkin-HKixBCOQz3hWk0Htik3J/w@public.gmane.org
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1401973080-10085-1-git-send-email-abrodkin-HKixBCOQz3hWk0Htik3J/w@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Alexey Brodkin <Alexey.Brodkin-HKixBCOQz3hWk0Htik3J/w@public.gmane.org>
Date: Thu,  5 Jun 2014 16:58:00 +0400

> On some platforms existing 100 msecond delay is not enough for DMA block to
> recover after reset. This is because MAC DMA waits for all PHY input clocks
> to present and depending on the board reset bit deassertion may take much
> longer than previously used 100 milliseconds
> 
> I have a board that requires more than 2 seconds for DMA to zero "reset" bit.
> If for other boards it's still not long enough this value should be extended
> once again.
> 
> In the same change I convert "mdelay" to "msleep" to make CPU available for
> other processes during DMA init delay which is especially useful in case of
> delay for a few seconds.
> 
> Signed-off-by: Alexey Brodkin <abrodkin-HKixBCOQz3hWk0Htik3J/w@public.gmane.org>

This will not work, you cannot sleep with spinlocks held, and this code is
absolutely called in such a context.

For example stmmac_resume() --> stmmac_hw_setup() -> stmmac_init_dma_engine().

stmmac_resume() holds priv->lock over all of these operations, and even has
interrupts disabled.
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
