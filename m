From: Zach Brown <zach.brown@ni.com>
Subject: Re: [PATCH v4 3/3] net: phy: leds: add support for led triggers on
 phy link state change
Date: Thu, 13 Oct 2016 10:42:46 -0500
Message-ID: <20161013154246.GA17387@zach-desktop>
References: <1476217580-21229-1-git-send-email-zach.brown@ni.com>
 <1476217580-21229-4-git-send-email-zach.brown@ni.com>
 <20161013.104634.2079376697690971907.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <f.fainelli@gmail.com>, <mlindner@marvell.com>,
        <stephen@networkplumber.org>, <netdev@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>, <devel@driverdev.osuosl.org>,
        <florian.c.schilhabel@googlemail.com>, <Larry.Finger@lwfinger.net>,
        <gregkh@linuxfoundation.org>, <rpurdie@rpsys.net>,
        <j.anaszewski@samsung.com>, <linux-leds@vger.kernel.org>,
        <andrew@lunn.ch>
To: David Miller <davem@davemloft.net>
Return-path: <linux-leds-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20161013.104634.2079376697690971907.davem@davemloft.net>
Sender: linux-leds-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Oct 13, 2016 at 10:46:34AM -0400, David Miller wrote:
> From: Zach Brown <zach.brown@ni.com>
> Date: Tue, 11 Oct 2016 15:26:20 -0500
> 
> > From: Josh Cartwright <josh.cartwright@ni.com>
> > 
> > Create an option CONFIG_LED_TRIGGER_PHY (default n), which will
> > create a set of led triggers for each instantiated PHY device.  There is
> > one LED trigger per link-speed, per-phy.
> > 
> > This allows for a user to configure their system to allow a set of LEDs
> > to represent link state changes on the phy.
> > 
> > Signed-off-by: Josh Cartwright <josh.cartwright@ni.com>
> > Signed-off-by: Nathan Sullivan <nathan.sullivan@ni.com>
> > Signed-off-by: Zach Brown <zach.brown@ni.com>
>  ...
> > +	static const char * const name_suffix[] = {
> > +		"10Mbps",
> > +		"100Mbps",
> > +		"1Gbps",
> > +		"2.5Gbps",
> > +		"10Gbps",
> 
> This choice of both the array size and the speeds to support seems
> entirely arbitrary and is inappropriate for a generic driver of this
> kind.
> 
> This seems to be hard coding this to support the list of speeds
> supported by whatever driver you want to use with this new LED
> facility, and sorry that's not how we build nice generic pieces of
> infrastructure.
> 
> Thanks.

The speeds listed are the speeds found in the phy_speed_to_str function in phy.c.
They are also the speeds found in the struct phy_setting settings array,
which is commented with
"/* A mapping of all SUPPORTED settings to speed/duplex */"
We believed they represented the commonly supported speeds of phys.

Do you have suggestions on how to better handle the choice of the array size
and the speeds?

Thanks.
