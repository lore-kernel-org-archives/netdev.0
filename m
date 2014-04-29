From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH net-next 5/7] net:fec: add support for dumping transmit
 ring on timeout
Date: Tue, 29 Apr 2014 13:38:29 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D0F7014F0@AcuExch.aculab.com>
References: <1398773350-7293-1-git-send-email-Frank.Li@freescale.com>
 <1398773350-7293-5-git-send-email-Frank.Li@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: 'Frank Li' <Frank.Li@freescale.com>,
	"lznuaa@gmail.com" <lznuaa@gmail.com>,
	"shawn.guo@linaro.org" <shawn.guo@linaro.org>,
	"B38611@freescale.com" <B38611@freescale.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"rmk+kernel@arm.linux.org.uk" <rmk+kernel@arm.linux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:50201 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1750827AbaD2NkY convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Apr 2014 09:40:24 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 25644-06 for <netdev@vger.kernel.org>;
 Tue, 29 Apr 2014 14:40:23 +0100 (BST)
In-Reply-To: <1398773350-7293-5-git-send-email-Frank.Li@freescale.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Of Frank Li
...
> When we timeout on transmit, it would be useful to dump the transmit
> ring, so we can see the ring state.  This can be helpful to diagnose
> the cause of transmit timeouts.
...
> +static void fec_dump(struct net_device *ndev)
> +{
> +	struct fec_enet_private *fep = netdev_priv(ndev);
> +	struct bufdesc *bdp = fep->tx_bd_base;
> +	unsigned index = 0;
> +
> +	netdev_info(ndev, "TX ring dump\n");
> +	pr_info("Nr     SC     addr       len  SKB\n");
> +
> +	do {
> +		pr_info("%3u %c%c 0x%04x 0x%08lx %4u %p\n",
> +			index,
> +			bdp == fep->cur_tx ? 'S' : ' ',
> +			bdp == fep->dirty_tx ? 'H' : ' ',
> +			bdp->cbd_sc, bdp->cbd_bufaddr, bdp->cbd_datlen,
> +			fep->tx_skbuff[index]);
> +		bdp = fec_enet_get_nextdesc(bdp, fep);
> +		index++;
> +	} while (bdp != fep->tx_bd_base);
> +}
> +

You probably want the read and write indexes as well.

	David
