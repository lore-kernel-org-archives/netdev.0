From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] Gigabit Ethernet driver of Topcliff PCH
Date: Thu, 26 Aug 2010 08:45:33 -0700
Message-ID: <20100826084533.1dfbd9bf@nehalam>
References: <4C763A67.5040107@dsn.okisemi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>,
	ML netdev <netdev@vger.kernel.org>,
	Greg Rose <gregory.v.rose@intel.com>,
	Maxime Bizon <mbizon@freebox.fr>,
	Kristoffer Glembo <kristoffer@gaisler.com>,
	Ralf Baechle <ralf@linux-mips.org>,
	John Linn <john.linn@xilinx.com>,
	Randy Dunlap <randy.dunlap@oracle.com>,
	"David S. Miller" <davem@davemloft.net>,
	MeeGo <meego-dev@meego.com>, "Wang, Qi" <qi.wang@intel.com>,
	"Wang, Yong Y" <yong.y.wang@intel.com>,
	Andrew <andrew.chih.howe.khor@intel.com>,
	Intel OTC <joel.clark@intel.com>,
	"Foster, Margie" <margie.foster@intel.com>,
	Toshiharu Okada <okada533@dsn.okisemi.com>,
	Tomoya Morinaga <morinaga526@dsn.okisemi.com>,
	Takahiro Shimizu <shimizu394@dsn.okisemi.com>
To: Masayuki Ohtake <masa-korg@dsn.okisemi.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:46331 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752309Ab0HZPpg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Aug 2010 11:45:36 -0400
In-Reply-To: <4C763A67.5040107@dsn.okisemi.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> +/**
> + * pch_gbe_mac_init_rx_addrs - Initialize receive address's
> + * @hw:	Pointer to the HW structure
> + * @mar_count: Receive address registers
> + */
> +void pch_gbe_mac_init_rx_addrs(struct pch_gbe_hw *hw, u16 mar_count)
> +{
> +	u32 i;
> +	PCH_GBE_DEBUG("pch_gbe_mac_init_rx_addrs\n");
> +
> +	/* Setup the receive address */
> +	pch_gbe_mac_mar_set(hw, hw->mac.addr, 0);
> +
> +	/* Zero out the other receive addresses */
> +	for (i = 1; i < mar_count; i++) {
> +		iowrite32(0, &hw->reg->mac_adr[i].high);
> +		iowrite32(0, &hw->reg->mac_adr[i].low);
> +	}
> +	iowrite32(0xFFFE, &hw->reg->ADDR_MASK);
> +	/* wait busy */
> +	while ((ioread32(&hw->reg->ADDR_MASK) & PCH_GBE_BUSY))
> +		;
> +}

Use cpu_relax here to allow other hyper-thread to run.
	/* wait busy */
	while ((ioread32(&hw->reg->ADDR_MASK) & PCH_GBE_BUSY))
		cpu_relax();
