From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: eepro testing positive EBUSY return by
 request_irq()?
Date: Mon, 03 Jan 2011 11:37:26 -0800 (PST)
Message-ID: <20110103.113726.246525147.davem@davemloft.net>
References: <4D1DECFC.8020701@gmail.com>
	<1293809262.2870.45.camel@localhost>
	<4D209127.5080505@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ben@decadent.org.uk, netdev@vger.kernel.org,
	akpm@linux-foundation.org, linux-kernel@vger.kernel.org
To: roel.kluin@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4D209127.5080505@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: roel kluin <roel.kluin@gmail.com>
Date: Sun, 02 Jan 2011 15:52:23 +0100

> +		for (i = 0; i < ARRAY_SIZE(irqlist); i++) {
> +			retval = request_irq (irqlist[i], NULL, 0, "bogus", NULL);
> +			if (retval != -EBUSY)
> +				continue;
> +			if (retval < 0)
> +				goto out;
> +			dev->irq = irqlist[i];
> +			break;

This series of tests don't make much sense.

If we get to the "retval < 0" check, retval must be -EBUSY.  So at
best it's superfluous, at worst it's confusing.
