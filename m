From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: [PATCH net-next v2 2/4] can: cc770: add legacy ISA bus driver for the CC770 and AN82527
Date: Wed, 11 Jan 2012 09:37:28 -0000
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6D8AF3B@saturn3.aculab.com>
References: <4F0D4FBA.1080108@essax.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Marc Kleine-Budde" <mkl@pengutronix.de>,
	"Oliver Hartkopp" <socketcan@hartkopp.net>, <henrik@proconx.com>,
	<netdev@vger.kernel.org>, <linux-can@vger.kernel.org>,
	<socketcan-users@lists.berlios.de>, "IreneV" <boir1@yandex.ru>,
	"Stanislav Yelenskiy" <stanislavelensky@yahoo.com>, <oe@port.de>,
	<henrik@focus-sw.com>
To: <info@essax.com>, "Wolfgang Grandegger" <wg@grandegger.com>
Return-path: <linux-can-owner@vger.kernel.org>
Content-class: urn:content-classes:message
In-Reply-To: <4F0D4FBA.1080108@essax.com>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

 
> @@ -689,12 +680,6 @@ static void cc770_tx_interrupt(struct 
> net_device *dev, unsigned int o)
>   	/* Nothing more to send, switch off interrupts */
>   	cc770_write_reg(priv, msgobj[mo].ctrl0,
>   			MSGVAL_RES | TXIE_RES | RXIE_RES | INTPND_RES);
> -	/*
> -	 * We had some cases of repeated IRQ so make sure the
> -	 * INT is acknowledged
> -	 */
> -	cc770_write_reg(priv, msgobj[mo].ctrl0,
> -			MSGVAL_UNC | TXIE_UNC | RXIE_UNC | INTPND_RES);

A wild guess is that this is needed to clear an interrupt
that was asserted during the ISR processing.
So you need to ack the IRQ as well as mask it.

Not sure if the difference between the xxx_UNC and xxx_RES
bits though.

	David


