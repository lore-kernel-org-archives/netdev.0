From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next] net: dsa: mv88e6xxx: Add watchdog interrupt
 handler
Date: Sun, 5 Feb 2017 17:52:59 +0100
Message-ID: <20170205165259.GB26564@lunn.ch>
References: <1486240734-13157-1-git-send-email-andrew@lunn.ch>
 <6936eb05-bec7-a898-6dae-875eda888ce1@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:56181 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751425AbdBEQxF (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 5 Feb 2017 11:53:05 -0500
Content-Disposition: inline
In-Reply-To: <6936eb05-bec7-a898-6dae-875eda888ce1@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> > +static irqreturn_t mv88e6xxx_g2_watchdog_thread_fn(int irq, void *dev_id)
> > +{
> > +	u16 reg;
> > +
> > +	struct mv88e6xxx_chip *chip = dev_id;
> > +
> > +	mv88e6xxx_g2_read(chip, GLOBAL2_WDOG_CONTROL, &reg);
> > +
> > +	dev_info(chip->dev, "Watchdog event: %04x", reg);
> 
> Should this be 0x%04x just to illustrate the value is hexadecimal? And

Yes, the prefix would make sense.

> should this be dev_info_once()?

Since the next action is to disable the interrupt, and there is no
code path to reenable it, _once does not seem needed. And if for some
reason the kernel log is spammed with these messages, i want to
know. It means my interrupt handling code is badly broken!

      Andrew
