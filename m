From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: [PATCH net-next v2 2/4] can: cc770: add legacy ISA bus driver for the CC770 and AN82527
Date: Tue, 10 Jan 2012 10:00:49 -0000
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6D8AF39@saturn3.aculab.com>
References: <4F0B608D.6090309@essax.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>, <linux-can@vger.kernel.org>,
	<socketcan-users@lists.berlios.de>, "IreneV" <boir1@yandex.ru>,
	"Stanislav Yelenskiy" <stanislavelensky@yahoo.com>, <oe@port.de>,
	<henrik@focus-sw.com>
To: <info@essax.com>, "Wolfgang Grandegger" <wg@grandegger.com>,
	"Oliver Hartkopp" <socketcan@hartkopp.net>, <henrik@proconx.com>
Return-path: <linux-can-owner@vger.kernel.org>
Content-class: urn:content-classes:message
In-Reply-To: <4F0B608D.6090309@essax.com>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

 
> cc770_isa_port_write_reg_indirect(const struct cc770_priv *priv,
>   						int reg, u8 val)
>   {
>   	unsigned long base = (unsigned long)priv->reg_base;
> +	unsigned long flags;
> 
> +	spin_lock_irqsave( &outb_lock, flags);
>   	outb(reg, base);
>   	outb(val, base + 1);
> +	spin_unlock_irqrestore( &outb_lock, flags);	

Is there a 'read_reg_indirect' function??
If so it also needs to use the same mutex.
I'd double check all references to the 'reg_base' field.

	David


