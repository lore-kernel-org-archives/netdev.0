From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 2/2] dsa: mv88e6xxx.c: Hardware reset the chip
 if available
Date: Thu, 19 Nov 2015 02:13:27 +0100
Message-ID: <20151119011327.GA25930@lunn.ch>
References: <1447889365-25256-1-git-send-email-andrew@lunn.ch>
 <1447889365-25256-3-git-send-email-andrew@lunn.ch>
 <564D0EFA.7050806@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
	Neil Armstrong <narmstrong@baylibre.com>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:36929 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756509AbbKSBNa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Nov 2015 20:13:30 -0500
Content-Disposition: inline
In-Reply-To: <564D0EFA.7050806@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> We are embedding reset logic here about the delays and polarity, while
> there is now a proper abstraction for this within the reset controller
> subsystem under drivers/reset/core.c. Could we utilize that facility
> instead which would make us more robust wrt. non-GPIO reset lines (for
> instance some SF2 switches on DSL gateways could definitively benefit
> from this).
> 
> There does not seem to be a reset controller GPIO binding and generic
> driver, but this seems like an appropriate candidate?

Hi Florian

That was my first thought as well. But then i went searching and found

http://permalink.gmane.org/gmane.linux.ports.arm.kernel/257149

where Mark Rutland says no to the idea. reset-gpios should be handle
by the device.

Anyway, delays are hard coded, but polarity not. That is in the
generic device tree binding for a GPIO, you can say GPIO_ACTIVE_LOW or
GPIO_ACTIVE_HIGH. The delays are also hard coded in the Marvell
specific part, so should not cause a problem to other manufactures
chips.

	Andrew
