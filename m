From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH 3/3] net: fec: align IP header in hardware
Date: Mon, 26 Sep 2016 09:26:33 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6DB0109865@AcuExch.aculab.com>
References: <AM4PR0401MB22609D8151C2B63CA7768A1AFFCB0@AM4PR0401MB2260.eurprd04.prod.outlook.com>
 <1474728139-9335-1-git-send-email-eric@nelint.com>
 <1474728139-9335-4-git-send-email-eric@nelint.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "linux@arm.linux.org.uk" <linux@arm.linux.org.uk>,
        "andrew@lunn.ch" <andrew@lunn.ch>,
        "fugang.duan@nxp.com" <fugang.duan@nxp.com>,
        "otavio@ossystems.com.br" <otavio@ossystems.com.br>,
        "edumazet@google.com" <edumazet@google.com>,
        "troy.kisky@boundarydevices.com" <troy.kisky@boundarydevices.com>,
        "davem@davemloft.net" <davem@davemloft.net>,
        "u.kleine-koenig@pengutronix.de" <u.kleine-koenig@pengutronix.de>
To: 'Eric Nelson' <eric@nelint.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out6.electric.net ([192.162.217.186]:50200 "EHLO
        smtp-out6.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1761370AbcIZJ3g (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 26 Sep 2016 05:29:36 -0400
In-Reply-To: <1474728139-9335-4-git-send-email-eric@nelint.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Nelson
> Sent: 24 September 2016 15:42
> The FEC receive accelerator (RACC) supports shifting the data payload of
> received packets by 16-bits, which aligns the payload (IP header) on a
> 4-byte boundary, which is, if not required, at least strongly suggested
> by the Linux networking layer.
...
> +		/* align IP header */
> +		val |= FEC_RACC_SHIFT16;

I can't help feeling that there needs to be corresponding
changes to increase the buffer size by 2 (maybe for large mtu)
and to discard two bytes from the frame length.

If probably ought to be predicated on NET_IP_ALIGN as well.

	David
