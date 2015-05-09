From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: [PATCH] net: fec: add support of ethtool get_regs
Date: Sat, 9 May 2015 22:17:46 +0100
Message-ID: <20150509211746.GY2067@n2100.arm.linux.org.uk>
References: <1431204728-16754-1-git-send-email-tremyfr@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, B38611@freescale.com, Frank.Li@freescale.com,
	LW@KARO-electronics.de, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Philippe Reynes <tremyfr@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1431204728-16754-1-git-send-email-tremyfr@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, May 09, 2015 at 10:52:08PM +0200, Philippe Reynes wrote:
> +static void fec_enet_get_regs(struct net_device *ndev,
> +			      struct ethtool_regs *regs, void *regbuf)
> +{
> +	struct fec_enet_private *fep = netdev_priv(ndev);
> +
> +	memcpy_fromio(regbuf, fep->hwp, regs->len);

Using memcpy_fromio() to copy device registers is not a good idea -
it can use a variable access size which can cause bus faults.

-- 
FTTC broadband for 0.8mile line: currently at 10.5Mbps down 400kbps up
according to speedtest.net.
