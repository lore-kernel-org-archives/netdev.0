From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: patch tulip-natsemi-dp83840a-phy-fix.patch added to -mm tree
Date: Mon, 16 May 2005 00:06:48 -0400
Message-ID: <42881C58.40001@pobox.com>
References: <200505101955.j4AJtX9x032464@shell0.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: T-Bone@parisc-linux.org, grundler@parisc-linux.org,
	varenet@parisc-linux.org,
	Linux Kernel <linux-kernel@vger.kernel.org>,
	Netdev <netdev@oss.sgi.com>
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S261261AbVEPEG4@vger.kernel.org>
To: akpm@osdl.org
In-Reply-To: <200505101955.j4AJtX9x032464@shell0.pdx.osdl.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

akpm@osdl.org wrote:
> +
> +					/* flush posted writes */
> +					ioread32(ioaddr + CSR15);
> +
> +					/* Sect 3.10.3 in DP83840A.pdf (p39) */
> +					udelay(500);
> +
> +					/* Section 4.2 in DP83840A.pdf (p43) */
> +					/* and IEEE 802.3 "22.2.4.1.1 Reset" */
> +					while (timeout-- &&
> +						(tulip_mdio_read (dev, phy_num, MII_BMCR) & BMCR_RESET))
> +						udelay(100);


Note that while the patch creates the correct behavior, the delays above 
occur inside spin_lock_irqsave() and/or timer context.

I have been to get HP to fix this patch's delay problem for -years-.

	Jeff
