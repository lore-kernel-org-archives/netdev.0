From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH net-next v2 07/10] net/faraday: Read MAC address from
 chip
Date: Tue, 19 Jul 2016 10:50:44 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D5F4FC97F@AcuExch.aculab.com>
References: <1468579460-13768-1-git-send-email-gwshan@linux.vnet.ibm.com>
 <1468579460-13768-8-git-send-email-gwshan@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"benh@kernel.crashing.org" <benh@kernel.crashing.org>,
	"joel@jms.id.au" <joel@jms.id.au>,
	"gerlitz.or@gmail.com" <gerlitz.or@gmail.com>,
	"weixue@trustnetic.com" <weixue@trustnetic.com>,
	"yuvali@mellanox.com" <yuvali@mellanox.com>,
	"alexei.starovoitov@gmail.com" <alexei.starovoitov@gmail.com>,
	"f.fainelli@gmail.com" <f.fainelli@gmail.com>
To: 'Gavin Shan' <gwshan@linux.vnet.ibm.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out4.electric.net ([192.162.216.183]:52973 "EHLO
	smtp-out4.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753028AbcGSKwk convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Jul 2016 06:52:40 -0400
In-Reply-To: <1468579460-13768-8-git-send-email-gwshan@linux.vnet.ibm.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gavin Shan
> Sent: 15 July 2016 11:44
> The device is assigned with random MAC address. It isn't reasonable.
> An valid MAC address might have been provided by (uboot) firmware by
> device-tree or in chip. It's reasonable to use it to maintain consistency.
> 
> This uses the MAC address from device-tree or that in the chip if it's
> valid. Otherwise, a random MAC address is given as before.
...
> +	m = ioread32(priv->base + FTGMAC100_OFFSET_MAC_MADR);
> +	l = ioread32(priv->base + FTGMAC100_OFFSET_MAC_LADR);
> +
> +	mac[0] = (m >> 8) & 0xff;
> +	mac[1] = m & 0xff;
> +	mac[2] = (l >> 24) & 0xff;
> +	mac[3] = (l >> 16) & 0xff;
> +	mac[4] = (l >> 8) & 0xff;
> +	mac[5] = l & 0xff;
> +
> +	if (!is_valid_ether_addr(mac)) {
> +		mac[5] = (m >> 8) & 0xff;
> +		mac[4] = m & 0xff;
> +		mac[3] = (l >> 24) & 0xff;
> +		mac[2] = (l >> 16) & 0xff;
> +		mac[1] = (l >>  8) & 0xff;
> +		mac[0] = l & 0xff;
> +	}
...

That is horrid, not all byte reversed addresses will be invalid.

	David
