From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [RFC 08/15] rtc: at91sam9: Add missing MFD_SYSCON dependency on HAS_IOMEM
Date: Thu, 03 Mar 2016 13:58:33 +0100
Message-ID: <4070388.ZbRf8kMntA@wuerfel>
References: <1456992221-26712-1-git-send-email-k.kozlowski@samsung.com> <2233190.1BxevBAvDE@wuerfel> <CAMuHMdXUdz0=n2+Aa74f1LtwiwfV9=gkPBiJKC_DMyr1_jBe7Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Geert Uytterhoeven <geert@linux-m68k.org>,
	Krzysztof Kozlowski <k.kozlowski@samsung.com>,
	Linus Walleij <linus.walleij@linaro.org>,
	Sebastian Reichel <sre@kernel.org>,
	David Brown <david.brown@linaro.org>,
	Alexandre Belloni <alexandre.belloni@free-electrons.com>,
	Laurent Pinchart <laurent.pinchart@ideasonboard.com>,
	Lee Jones <lee.jones@linaro.org>,
	Dan Williams <dan.j.williams@intel.com>,
	driverdevel <devel@driverdev.osuosl.org>,
	"linux-samsung-soc@vger.kernel.org"
	<linux-samsung-soc@vger.kernel.org>,
	Vinod Koul <vinod.koul@intel.com>,
	Daniel Lezcano <daniel.lezcano@linaro.org>,
	Kishon Vijay Abraham I <kishon@ti.com>,
	Andy Gross <andy.gross@linaro.org>,
	Linux Media Mailing List <linux-media@vger.kernel.org>,
	Jason Cooper <jason@lakedaemon.net>,
	RTCLINUX <rtc-linux@googlegroups.com>,
	Mauro Carvalho Chehab <mchehab@osg.samsung.com>,
	Marc Zyngier <marc.zyngier@arm.
To: linux-arm-kernel@lists.infradead.org
Return-path: <linux-arm-msm-owner@vger.kernel.org>
In-Reply-To: <CAMuHMdXUdz0=n2+Aa74f1LtwiwfV9=gkPBiJKC_DMyr1_jBe7Q@mail.gmail.com>
Sender: linux-arm-msm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thursday 03 March 2016 13:27:59 Geert Uytterhoeven wrote:
> On Thu, Mar 3, 2016 at 11:55 AM, Arnd Bergmann <arnd@arndb.de> wrote:
> > On Thursday 03 March 2016 17:03:34 Krzysztof Kozlowski wrote:
> >> index 0da40e2e4280..5c530b6b125d 100644
> >> --- a/drivers/rtc/Kconfig
> >> +++ b/drivers/rtc/Kconfig
> >> @@ -1302,6 +1302,7 @@ config RTC_DRV_AT91RM9200
> >>  config RTC_DRV_AT91SAM9
> >>         tristate "AT91SAM9 RTT as RTC"
> >>         depends on ARCH_AT91 || COMPILE_TEST
> >> +       depends on HAS_IOMEM    # For MFD_SYSCON
> >>         select MFD_SYSCON
> >>         help
> >>           Some AT91SAM9 SoCs provide an RTT (Real Time Timer) block which
> >>
> >
> > This is technically correct, but the entire RTC menu is hidden
> > inside of 'depends on !UML && !S390', so we won't ever get there
> > on any configuration that does not use HAS_IOMEM.
> >
> > If we did, all other RTC drivers would also fail.
> 
> So UML has no RTC. Should/can it use RTC_DRV_GENERIC?

I think nothing should use that, even if it could ;-)

Funny enough, RTC_DRV_GENERIC would probably actually work if you
run UML as root and set iopl() to allow port access, but we don't
really want it to mess with the host RTC.

I don't know where UML gets it real time, but it doesn't actually
need much other than calling clock_gettime(CLOCK_REALTIME, ...)
to get the host time. Presumably it uses some variation of that.

	Arnd
