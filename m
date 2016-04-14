From: Chen-Yu Tsai <wens@csie.org>
Subject: Re: [PATCH RFC 2/5] net: phy: sun8i-h3-ephy: Add driver for Allwinner
 H3 Ethernet PHY
Date: Thu, 14 Apr 2016 10:04:50 +0800
Message-ID: <CAGb2v65-V3Mt_aPJNdfEH6VFySGc_cBhqgbE_VR5tsBtPvVjfA@mail.gmail.com>
References: <1459786954-12649-1-git-send-email-wens@csie.org>
 <1459786954-12649-3-git-send-email-wens@csie.org> <570BF9A6.2040109@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Chen-Yu Tsai <wens@csie.org>,
	Maxime Ripard <maxime.ripard@free-electrons.com>,
	Rob Herring <robh+dt@kernel.org>,
	Pawel Moll <pawel.moll@arm.com>,
	Mark Rutland <mark.rutland@arm.com>,
	Ian Campbell <ijc+devicetree@hellion.org.uk>,
	Kumar Gala <galak@codeaurora.org>,
	netdev <netdev@vger.kernel.org>,
	linux-arm-kernel <linux-arm-kernel@lists.infradead.org>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	devicetree <devicetree@vger.kernel.org>,
	LABBE Corentin <clabbe.montjoie@gmail.com>,
	Andrew Lunn <andrew@lunn.ch>,
	Hans De Goede <hdegoede@redhat.com>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <570BF9A6.2040109@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Apr 12, 2016 at 3:23 AM, Florian Fainelli <f.fainelli@gmail.com> wrote:
> On 04/04/16 09:22, Chen-Yu Tsai wrote:
>> The Allwinner H3 SoC incorporates an Ethernet PHY. This is enabled and
>> configured through a memory mapped hardware register.
>>
>> This same register also configures the MAC interface mode and TX clock
>> source. Also covered by the register, but not supported in this driver,
>> are TX/RX clock delay chains and inverters, and an RMII module.
>
> This is not really a PHY driver, more a driver for a special piece of
> hardware responsible for properly configuring a more standard integrated
> PHY which is then driven via standard MDIO accesses, right?
>
> The intention to make this driver re-usable is fine, but still makes me
> wonder if it should not be put in a file which is linked into the
> Ethernet MAC driver, and utilized by this one in a way that may be more
> "ad-hoc" than what you are proposing here.
>
> One thing that is not obvious here, is how is the device parenting done?
> Are we able to associate a phy_device to this SUN8I_H3_EPHY platform
> device here?

AFAIK you can't tie a platform device to an MDIO bus and phy_device.
I looked around for any examples and found none.

We're going to run into a similar issue with an MFD device later on.
The X-Powers AC200 is a I2C based combo chip which includes an Ethernet
PHY.

> Another thing is that the Ethernet MAC driver is fully aware of when
> putting an Ethernet PHY into suspend, shutdown, or fully functional
> power state should occur, if you have a separate platform driver here
> which does not listen for such kinds of events (hint: none are generated
> right now), then you cannot implement a working power state interface
> between the MAC, SHIM and PHY here, even though you would want that.

For this particular piece of hardware it would be possible to move the
code into the MAC driver itself. For the AC200, not so much. Using the
generic PHY framework to do power up / down would be a possibility.


Regards
ChenYu
