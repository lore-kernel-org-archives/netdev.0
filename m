From: Grazvydas Ignotas <notasas@gmail.com>
Subject: Re: [PATCH 2/4] wl1251: move power GPIO handling into the driver
Date: Mon, 28 Oct 2013 19:29:52 +0200
Message-ID: <CANOLnONKcC1i19ypb4rh2Rff3WsVhhuUhNvZvYwDV2-ZNtjVxQ@mail.gmail.com>
References: <1382890469-25286-1-git-send-email-sre@debian.org>
	<1382890469-25286-3-git-send-email-sre@debian.org>
	<1382891056.102746625@f315.i.mail.ru>
	<20131027201218.GA4414@earth.universe>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: Alexander Shiyan <shc_work@mail.ru>,
	Luciano Coelho <luca@coelho.fi>,
	Mark Rutland <mark.rutland@arm.com>,
	devicetree@vger.kernel.org, Russell King <linux@arm.linux.org.uk>,
	Pawel Moll <pawel.moll@arm.com>,
	Ian Campbell <ijc+devicetree@hellion.org.uk>,
	Tony Lindgren <tony@atomide.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Stephen Warren <swarren@wwwdotorg.org>,
	linux-doc@vger.kernel.org,
	"John W. Linville" <linville@tuxdriver.com>,
	Rob Herring <rob.herring@calxeda.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Sachin Kamat <sachin.kamat@linaro.org>,
	Bill Pemberton <wfp5p@virginia.edu>,
	Felipe Balbi <balbi@ti.com>, Rob Landley <rob@landley.net>,
	netdev@vger.kernel.org,
	"linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	"linux-omap@vger.kernel.org" <linux-omap@vger.kernel.org>,
	"linux-arm-kernel@lists.infradead.org"
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <20131027201218.GA4414@earth.universe>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Oct 27, 2013 at 10:12 PM, Sebastian Reichel <sre@debian.org> wr=
ote:
> On Sun, Oct 27, 2013 at 08:24:16PM +0400, Alexander Shiyan wrote:
>> > Move the power GPIO handling from the board code into
>> > the driver. This is a dependency for device tree support.
>> >
>> > Signed-off-by: Sebastian Reichel <sre@debian.org>
>> > ---
>> >  arch/arm/mach-omap2/board-omap3pandora.c     |  2 ++
>> >  arch/arm/mach-omap2/board-rx51-peripherals.c | 11 ++--------
>> >  drivers/net/wireless/ti/wl1251/sdio.c        | 21 +++++++++++++--=
---
>> >  drivers/net/wireless/ti/wl1251/spi.c         | 33 +++++++++++++++=
+++----------
>> >  drivers/net/wireless/ti/wl1251/wl1251.h      |  2 +-
>> >  include/linux/wl12xx.h                       |  2 +-
>> >  6 files changed, 43 insertions(+), 28 deletions(-)
>> ...
>> > diff --git a/include/linux/wl12xx.h b/include/linux/wl12xx.h
>> > index b516b4f..a9c723b 100644
>> > --- a/include/linux/wl12xx.h
>> > +++ b/include/linux/wl12xx.h
>> > @@ -49,7 +49,7 @@ enum {
>> >  };
>> >
>> >  struct wl1251_platform_data {
>> > -   void (*set_power)(bool enable);
>> > +   int power_gpio;
>> >     /* SDIO only: IRQ number if WLAN_IRQ line is used, 0 for SDIO =
IRQs */
>> >     int irq;
>> >     bool use_eeprom;
>> > --
>>
>> What a reason for not using regulator API here with GPIO-based
>> regulator?
>
> I think this pin is not used as power supply, but like an enable pin
> for low power states. Of course the regulator API could still be
> (mis?)used for this, but I think it would be the first linux device
> driver doing this.
>
> Note: I don't have wl1251 documentation.

When wl12xx family of chips is connected through SDIO, we already have
that pin set up as a regulator controlled with the help of mmc
subsystem. When time comes to communicate with the chip, mmc subsystem
sees this as yet another SD card and looks for associated regulator
for it, and the board file has that set up as a fixed regulator
controlling that pin (see pandora_vmmc3 in
arch/arm/mach-omap2/board-omap3pandora.c). To prevent poweroff after
first SDIO communications are over, pm_runtime calls are used in
drivers/net/wireless/ti/wl1251/sdio.c .

I don't know if something similar can be done done in SPI case, but
I'm sure this is not the first your-so-called regulator misuse.

Gra=C5=BEvydas
