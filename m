From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH v2 09/15] net: dsa: Add support for switch EEPROM access
Date: Mon, 27 Oct 2014 14:59:17 +0100
Message-ID: <20141027135917.GA12627@lunn.ch>
References: <1414342365-27191-1-git-send-email-linux@roeck-us.net>
 <1414342365-27191-10-git-send-email-linux@roeck-us.net>
 <20141027024121.GA16998@lunn.ch>
 <544DC264.9020600@roeck-us.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Lunn <andrew@lunn.ch>, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	linux-kernel@vger.kernel.org
To: Guenter Roeck <linux@roeck-us.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <544DC264.9020600@roeck-us.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> So lets take a step back: For the Marvell chips, I have to provide both length
> and presence in devicetree or platform data. Presence seemed to be implied by
> length, so I used only a single property and variable to indicate both.

Hi Guenter

What i was thinking, is that you don't need length in device tree. The
datasheet specifies how big the EEPROM needs to be.

However, i read the datasheet for the 6060, the only public datasheet
from Marvell. It does not work as i expected. Rather than being a
fixed list of register values, it is a variable length list of
command/value pairs.

In this situation, yes, you do need the length in DT.

I had a quick look at some other switch chips. e.g. the RTL8100. It
has a fixed layout of its EEPROM, consisting of 0x80 bytes. In this
case, the switch driver could be hard coded with 0x80, and all DT
needs to indicate is if the EEPROM is present or not.

So, what you have proposed will work. It is maybe not optimal in the
case of a well defined in the datasheet fixed size EEPROM, but it
still works.

Acked-by: Andrew Lunn <andrew@lunn.ch>

	  Andrew
