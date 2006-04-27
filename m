From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [patch 2/9] tulip: NatSemi DP83840A PHY fix
Date: Thu, 27 Apr 2006 05:52:55 -0400
Message-ID: <44509477.4010001@garzik.org>
References: <200604270932.k3R9W4Xj025312@shell0.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, T-Bone@parisc-linux.org,
	grundler@parisc-linux.org, jgarzik@pobox.com,
	varenet@parisc-linux.org, Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:933 "EHLO mail.dvmed.net")
	by vger.kernel.org with ESMTP id S965063AbWD0JxB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Apr 2006 05:53:01 -0400
To: akpm@osdl.org
In-Reply-To: <200604270932.k3R9W4Xj025312@shell0.pdx.osdl.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

akpm@osdl.org wrote:
> +				if (startup) {
> +					int timeout = 10;	/* max 1 ms */
>  					for (i = 0; i < reset_length; i++)
>  						iowrite32(get_u16(&reset_sequence[i]) << 16, ioaddr + CSR15);
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


What can we do about this?

Its a huge delay to be taken inside a spinlock.

Anybody interested to converting the driver to use schedule_work() or 
similar?

	Jeff


