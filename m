From: Zach Brown <zach.brown@ni.com>
Subject: Re: [PATCH v5 4/4] net: phy: leds: add support for led triggers on
 phy link state change
Date: Tue, 18 Oct 2016 09:50:07 -0500
Message-ID: <20161018145007.GA16835@zach-desktop>
References: <1476719395-28273-1-git-send-email-zach.brown@ni.com>
 <1476719395-28273-5-git-send-email-zach.brown@ni.com>
 <20161018071350.GG26778@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <f.fainelli@gmail.com>, <mlindner@marvell.com>,
        <stephen@networkplumber.org>, <netdev@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>, <devel@driverdev.osuosl.org>,
        <florian.c.schilhabel@googlemail.com>, <Larry.Finger@lwfinger.net>,
        <gregkh@linuxfoundation.org>, <rpurdie@rpsys.net>,
        <j.anaszewski@samsung.com>, <linux-leds@vger.kernel.org>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <linux-leds-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20161018071350.GG26778@lunn.ch>
Sender: linux-leds-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Oct 18, 2016 at 09:13:50AM +0200, Andrew Lunn wrote:
> On Mon, Oct 17, 2016 at 10:49:55AM -0500, Zach Brown wrote:
> > Create an option CONFIG_LED_TRIGGER_PHY (default n), which will create a
> > set of led triggers for each instantiated PHY device. There is one LED
> > trigger per link-speed, per-phy.
> > The triggers are registered during phy_attach and unregistered during
> > phy_detach.
> >
> > This allows for a user to configure their system to allow a set of LEDs
> > not controlled by the phy to represent link state changes on the phy.
> > LEDS controlled by the phy are unaffected.
> >
> > For example, we have a board where some of the leds in the
> > RJ45 socket are controlled by the phy, but others are not. Using the
> > triggers provided by this patch the leds not controlled by the phy can
> > be configured to show the current speed of the ethernet connection. The
> > leds controlled by the phy are unaffected.
>
> Is there a clear path how we generalise this, so it could also be used
> to control PHY LEDs?
>

No, this patch set is only concerned with generic LEDs not PHY LEDs.

> The idea i had a while ago was that the PHY LEDS would also have a
> list of triggers which mapped to what the PHY controller could do. So
> to enable the PHY LED to show RxTx activity, you would enable the RxTx
> trigger on the PHY LED.
>
> This needs an extension to the PHY code, in that these triggers are
> specific to the LED, not general across all LEDs. But this is not too
> big an issue.
>
> We could end up that if a PHY LED can be used as a generic LED, your
> 'manual' trigger could be used on it. But it could also support the
> PHY driven 'automatic' link status indication trigger. Do we want two
> triggers for the same or similar information?
>

If generic LEDs can only use the 'manual' triggers then having two triggers
for the same or similar information would be okay. The focus of this patch set
was to allow generic LEDs to represent the current speed of the phy, which is
very useful when the PHY LEDs don't for whatever reason i.e they don't exist or
are busy representing another aspect.
