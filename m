From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: mdio-gpio: support access that may sleep
Date: Fri, 24 Apr 2015 11:04:55 -0400 (EDT)
Message-ID: <20150424.110455.2117537129018647564.davem@davemloft.net>
References: <1429722414-18173-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, f.fainelli@gmail.com,
	linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com
To: vivien.didelot@savoirfairelinux.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1429722414-18173-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Date: Wed, 22 Apr 2015 13:06:54 -0400

> Some systems using mdio-gpio may use gpio on message based busses, which
> require sleeping (e.g. gpio from an I2C I/O expander).
> 
> Since this driver does not use IRQ handler, it is safe to use the
> _cansleep suffixed gpio accessors.
> 
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

Since this is down underneath the layer of an MII bus, you cannot
universally say that these routines are always called in a sleepable
context.

The PHY layer, and the driver itself above that, might call these
routines from timers, interruptes etc.

In fact, since the whole point of this driver is to provide a specific
implementation for programming registers over an MII bus, it's quite
rediculuous to say that just because interrupts are not used in this
implementation it means that sleeping is always valid.

You have to look at all of the (real and potential) users, all the way
up into the specific ethernet drivers.

Sorry I'm not applying this.
