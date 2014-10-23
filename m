From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH 06/14] net: dsa: Add support for hardware monitoring
Date: Thu, 23 Oct 2014 20:03:57 +0200
Message-ID: <20141023180357.GG25190@lunn.ch>
References: <1414037002-25528-1-git-send-email-linux@roeck-us.net>
 <1414037002-25528-7-git-send-email-linux@roeck-us.net>
 <CAGVrzcYjPJWai9bxkh+WRrEEAzBKBd-LQm7zDeeouxngr_v9SQ@mail.gmail.com>
 <54488CE1.2000106@roeck-us.net>
 <20141023134706.GB25190@lunn.ch>
 <20141023162754.GA21343@roeck-us.net>
 <20141023165459.GE25190@lunn.ch>
 <20141023173847.GA22988@roeck-us.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Lunn <andrew@lunn.ch>,
	Florian Fainelli <f.fainelli@gmail.com>,
	netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Guenter Roeck <linux@roeck-us.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20141023173847.GA22988@roeck-us.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> No, I am not saying that. The hwmon device's parent device will tell,
> which is how it works for all other hwmon devices.

O.K, so parent is important.

> Not really. Again, the parent device provides that information. libsensors,
> which is the preferred way of accessing sensors information from user space,
> provides the parent device instance as part of the logical sensor device
> name. In this case, the names will end up being dsa-isa-0000, dsa-isa-0001,
> and so on. With your added tags it would be dsa.0.0-isa-0000, dsa.0.1-isa-0001,
> and so on. I don't see how this would add any value.

isa is the name of the ethernet device? Why is it not eth0? Most
Marvell SoCs used in WiFi Access Points have multiple ethernet
interfaces, so i would hope the parent actually identifies which
ethernet interface it is hanging off.

Now consider the example in

http://lxr.free-electrons.com/source/Documentation/devicetree/bindings/net/dsa/dsa.txt

We have two switches hanging off one ethernet interface. What will the
naming look like in this case?

The Marvell DSA tagging scheme allows you to have 16 switches hanging
off one ethernet interface. How is the naming going to work then,
especially if there is a mixture of switch chips, some with
temperature sensors, and some without?

What would really help is if each switch has a device in the linux
device model. The hwmon parent would then be the switch device. The
EEPROM would then hang off the switch device, not an interface on the
switch device, etc.

	    Andrew
