From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v4] lpc32xx: Added ethernet driver
Date: Mon, 05 Mar 2012 16:49:18 -0800
Message-ID: <1330994958.9504.2.camel@edumazet-glaptop>
References: <1330983641-32622-1-git-send-email-stigge@antcom.de>
	 <1330987524.2538.61.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Roland Stigge <stigge@antcom.de>, davem@davemloft.net,
	jeffrey.t.kirsher@intel.com, alexander.h.duyck@intel.com,
	eilong@broadcom.com, ian.campbell@citrix.com,
	netdev@vger.kernel.org, w.sang@pengutronix.de,
	linux-kernel@vger.kernel.org, kevin.wells@nxp.com,
	linux-arm-kernel@lists.infradead.org, arnd@arndb.de,
	baruch@tkos.co.il, joe@perches.com
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1330987524.2538.61.camel@bwh-desktop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2012-03-05 at 22:45 +0000, Ben Hutchings wrote:
> On Mon, 2012-03-05 at 22:40 +0100, Roland Stigge wrote:
> [...]

...

> > +				/* Copy packet from buffer */
> > +				memcpy(prdbuf,
> > +					pldat->rx_buff_v[rxconsidx], len);
> > +
> > +				/* Pass to upper layer */
> > +				skb->protocol = eth_type_trans(skb, ndev);
> > +				netif_rx(skb);
> > +				ndev->last_rx = jiffies;
> 
> Drivers don't need to set last_rx any more.

Also, a NAPI driver should call netif_receive_skb() instead of
netif_rx()

netif_rx() is more expensive because of additional queue, while
netif_receive_skb() directly calls the upper stacks.
