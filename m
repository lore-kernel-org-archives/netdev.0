From: Alexander Stein <alexander.stein@systec-electronic.com>
Subject: Re: [PATCH 1/1 RFC] net/phy: Add Lantiq PHY driver
Date: Mon, 23 May 2016 11:49:36 +0200
Message-ID: <8983627.qbi7VGpM7G@ws-stein>
References: <1463587403-26809-1-git-send-email-alexander.stein@systec-electronic.com> <6103030.g2sqFmaRhG@ws-stein> <9231D502B07C5E4A8B32D5115C9F19991E917469@IRSMSX101.ger.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Mathias Kresin <openwrt@kresin.me>,
	John Crispin <john@phrozen.org>,
	Florian Fainelli <f.fainelli@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"andrew@lunn.ch" <andrew@lunn.ch>,
	Hauke Mehrtens <hauke@hauke-m.de>
To: "Mehrtens, Hauke" <hauke.mehrtens@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <9231D502B07C5E4A8B32D5115C9F19991E917469@IRSMSX101.ger.corp.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Hauke,

On Monday 23 May 2016 09:12:54, Mehrtens, Hauke wrote:
> > On Thursday 19 May 2016 12:03:10, Mathias Kresin wrote:
> > > 2016-05-19 9:03 GMT+02:00 John Crispin <john@phrozen.org>:
> > > > On 19/05/2016 08:57, Alexander Stein wrote:
> > > >> Thanks for the link, I wasn't aware of that patch. I like it in
> > > >> general, but there are some things I'd like to get addressed first:
> > > >> * vr9_gphy_of_reg_init() writes uncoditionally to led3h and led3l
> > > >> even on
> > > >> 
> > > >>   PEf7071 which does not have this register at all
> > > > 
> > > > we use this driver mainly on the 11g and 22f version. mathias
> > > > recently added the led3 handling.
> > > > 
> > > > @Mathias, can you have a look at this and fix it inside the lede tree
> > > > ?
> > > 
> > > Well, I haven't added the led3 handling, I've only changed the initial
> > > value (function) of led3.
> > > 
> > > Maybe it's cleaner to not use a default value for the led function and
> > > completely rely on the device tree bindings. But by adjusting the
> > > initial values, I had to change only the led function of one board in
> > > the openwrt xrx200 subtarget instead of touching all dts files.
> > 
> > I think setting default values is good.
> 
> The registers are set to some reset values after the chip is coming out of
> reset, but we should set  them all to the same value, Mathias said that all
> except for one board he knows are using only one LED per port, but they are
> often using different LED pins, I will change my patch.

One LED per port? I would think of using one RJ45 socket per port which 
usually have 2 LEDs.

> > > I know that the LTQ Datasheet for the PEF 7071 Version 1.5 mentions
> > > the led3 control register albeit there is no pin for a forth led. So I
> > > guess it's safe to write to the led3 register even for the PEF 7071.
> > 
> > Mh, my PEF 7071 User Manual (Version 2.0, 2012-10-17) doesn't mention
> > LED3x registers. There is LED3DA and LED3EN in PHY_LED but was removed in
> > 1.6 manual.
> 
> LED3x is only available in PEF 7072 which is a different package with more
> pins for the LED3 and some other interfaces.
> > I think, some flag if the PHY supports LED3 and depend on that is just
> > fine.
> I do not know how to distinguish between PEF 7071 and PEF 7072.

I expected that PEF 7072 would have a different PHY ID, but apparently this is 
not the case, though I don't have a datasheet for 7072. Is there really no way 
to distinguish those two?

Alexander
