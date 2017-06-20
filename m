From: Alexandre Belloni <alexandre.belloni-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>
Subject: Re: [PATCH 00/51] rtc: stop using rtc deprecated functions
Date: Tue, 20 Jun 2017 12:07:57 +0200
Message-ID: <20170620100757.d7dulehry67qknip@piout.net>
References: <1497951359-13334-1-git-send-email-benjamin.gaignard@linaro.org>
 <20170620100348.zh4ygvjjgnhxvmvl@piout.net>
Reply-To: rtc-linux-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: linaro-kernel-cunTk1MwBs8s++Sfvej+rw@public.gmane.org,
	adi-buildroot-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org,
	Alessandro Zummo <a.zummo-BfzFCNDTiLLj+vYz1yj4TQ@public.gmane.org>,
	Gregory Clement <gregory.clement-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>,
	Ingo Molnar <mingo-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Jason Cooper <jason-NLaQJdtUoK4Be96aLqz0jA@public.gmane.org>,
	John Stultz <john.stultz-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>,
	linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Linus Walleij <linus.walleij-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>,
	Michael Chan <michael.chan-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	rtc-linux-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org,
	Sebastian Hesselbarth <sebastian.hesselbarth-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Support Opensource <support.opensource-WBD+wuPFNBhBDgjK7y7TUQ@public.gmane.org>,
	Thomas Gleixner <tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org>, x86-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org,
	Baruch Siach <baruch-NswTu9S1W3P6gbPvEgmw2w@public.gmane.org>,
	Hans Ulli Kroll <ulli.kroll-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org>,
	Vladimir Zapolskiy <vz-ChpfBGZJDbMAvxtiuMwx3w@public.gmane.org>,
	Sylvain Lemieux <slemieux.tyco-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Barry Song <baohua-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Maxime Ripard <maxime.ripard@free-electrons.
To: Benjamin Gaignard <benjamin.gaignard-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
Return-path: <rtc-linux+bncBCKYNX7Y3IMBB77HUPFAKGQEZDPOZCA-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
Sender: rtc-linux-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
Content-Disposition: inline
In-Reply-To: <20170620100348.zh4ygvjjgnhxvmvl-m++hUPXGwpdeoWH0uzbU5w@public.gmane.org>
List-Post: <https://groups.google.com/group/rtc-linux/post>, <mailto:rtc-linux-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Help: <https://groups.google.com/support/>, <mailto:rtc-linux+help-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Archive: <https://groups.google.com/group/rtc-linux
List-Subscribe: <https://groups.google.com/group/rtc-linux/subscribe>, <mailto:rtc-linux+subscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Unsubscribe: <mailto:googlegroups-manage+712029733259+unsubscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>,
 <https://groups.google.com/group/rtc-linux/subscribe>
List-Id: netdev.vger.kernel.org

On 20/06/2017 at 12:03:48 +0200, Alexandre Belloni wrote:
> On 20/06/2017 at 11:35:08 +0200, Benjamin Gaignard wrote:
> > rtc_time_to_tm() and rtc_tm_to_time() are deprecated because they
> > rely on 32bits variables and that will make rtc break in y2038/2016.
> 
> Please don't, because this hide the fact that the hardware will not
> handle dates in y2038 anyway and as pointed by Russell a few month ago,
> rtc_time_to_tm will be able to catch it but the 64 bit version will
> silently ignore it.
> 

Just to be clear, it is fine on your ST hardware because it uses a 64bit
counter. Most of the one you patched are using 32 bit counters and so
will break anyway.

> 
> > The goal of this series of patches is ti stop using those two functions
> > and use instead to safer 64bits ones.
> > 
> > It also remove change .set_mmss to set_mmss64 callback for the same reasons.
> > 
> > Those 51 patches almost clean all the drivers except the few that I haven't
> > been able to compile because of cross-toolchains issues (au1xxx, mpc5121, ps3,
> > puv3, sun4v, tx4939, starfire, ls1x ...)
> > 
> > Obviously I don't have all those hardwares in my hands so I have only check
> > that the patches compile without warnings but it up to each maintainer to
> > valid them on real hardware.
> > 
> > Benjamin Gaignard (51):
> >   x86: rtc: stop using rtc deprecated functions
> >   x86: intel-mid: vrtc: stop using rtc deprecated functions
> >   net: broadcom: stop using rtc deprecated functions
> >   rtc: 88pm80x: stop using rtc deprecated functions
> >   rtc: 88pm860x: stop using rtc deprecated functions
> >   rtc: ab-b5ze-s3: stop using rtc deprecated functions
> >   rtc: ab8500: stop using rtc deprecated functions
> >   rtc: armada38x: stop using rtc deprecated functions
> >   rtc: at32ap700x: stop using rtc deprecated functions
> >   rtc: at91sam9: stop using rtc deprecated functions
> >   rtc: bfin: stop using rtc deprecated functions
> >   rtc: coh901331: stop using rtc deprecated functions
> >   rtc: cpcap: stop using rtc deprecated functions
> >   rtc: da9063: stop using rtc deprecated functions
> >   rtc: da9063: stop using rtc deprecated functions
> >   rtc: davinci: stop using rtc deprecated functions
> >   rtc: digicolor: stop using rtc deprecated functions
> >   rtc: dm355evm: stop using rtc deprecated functions
> >   rtc: ds1305: stop using rtc deprecated functions
> >   rtc: ds1374: stop using rtc deprecated functions
> >   rtc: ds1511: stop using rtc deprecated functions
> >   rtc: ds1553: stop using rtc deprecated functions
> >   rtc: ds1672: stop using rtc deprecated functions
> >   rtc: ds2404: stop using rtc deprecated functions
> >   rtc: ep93xx: stop using rtc deprecated functions
> >   rtc: gemini: stop using rtc deprecated functions
> >   rtc: imxdi: stop using rtc deprecated functions
> >   rtc: jz4740: stop using rtc deprecated functions
> >   rtc: lpc32xx: stop using rtc deprecated functions
> >   rtc: mv: stop using rtc deprecated functions
> >   rtc: omap: stop using rtc deprecated functions
> >   rtc: pcap: stop using rtc deprecated functions
> >   rtc: pl030: stop using rtc deprecated functions
> >   rtc: pl031: stop using rtc deprecated functions
> >   rtc: pm8xxx: stop using rtc deprecated functions
> >   rtc: rs5c348: stop using rtc deprecated functions
> >   rtc: sa1100: stop using rtc deprecated functions
> >   rtc: sh: stop using rtc deprecated functions
> >   rtc: sirfsoc: stop using rtc deprecated functions
> >   rtc: snvs: stop using rtc deprecated functions
> >   rtc: stk17ta8: stop using rtc deprecated functions
> >   rtc: stmp3xxx: stop using rtc deprecated functions
> >   rtc: sun6i: stop using rtc deprecated functions
> >   rtc: sysfs: stop using rtc deprecated functions
> >   rtc: tegra stop using rtc deprecated functions
> >   rtc: test: stop using rtc deprecated functions
> >   rtc: tps6586: stop using rtc deprecated functions
> >   rtc: vr41xx: stop using rtc deprecated functions
> >   rtc: wm831x: stop using rtc deprecated functions
> >   rtc: xgene stop using rtc deprecated functions
> >   power: suspend test: stop using rtc deprecated functions
> > 
> >  arch/x86/kernel/rtc.c                        |  6 ++--
> >  arch/x86/platform/intel-mid/intel_mid_vrtc.c |  2 +-
> >  drivers/net/ethernet/broadcom/bnxt/bnxt.c    |  2 +-
> >  drivers/rtc/rtc-88pm80x.c                    | 44 +++++++++++++--------------
> >  drivers/rtc/rtc-88pm860x.c                   | 40 ++++++++++++-------------
> >  drivers/rtc/rtc-ab-b5ze-s3.c                 | 45 ++++++++--------------------
> >  drivers/rtc/rtc-ab8500.c                     | 26 ++++++++--------
> >  drivers/rtc/rtc-armada38x.c                  | 34 +++++++++------------
> >  drivers/rtc/rtc-at32ap700x.c                 | 29 ++++++++----------
> >  drivers/rtc/rtc-at91sam9.c                   | 18 ++++-------
> >  drivers/rtc/rtc-bfin.c                       | 24 +++++++--------
> >  drivers/rtc/rtc-coh901331.c                  | 14 +++++----
> >  drivers/rtc/rtc-cpcap.c                      |  8 ++---
> >  drivers/rtc/rtc-da9052.c                     |  8 ++---
> >  drivers/rtc/rtc-da9063.c                     |  8 ++---
> >  drivers/rtc/rtc-davinci.c                    |  8 ++---
> >  drivers/rtc/rtc-digicolor.c                  |  4 +--
> >  drivers/rtc/rtc-dm355evm.c                   |  6 ++--
> >  drivers/rtc/rtc-ds1305.c                     | 11 +++----
> >  drivers/rtc/rtc-ds1374.c                     |  6 ++--
> >  drivers/rtc/rtc-ds1511.c                     |  2 +-
> >  drivers/rtc/rtc-ds1553.c                     |  2 +-
> >  drivers/rtc/rtc-ds1672.c                     |  8 ++---
> >  drivers/rtc/rtc-ds2404.c                     |  8 ++---
> >  drivers/rtc/rtc-ep93xx.c                     | 10 +++----
> >  drivers/rtc/rtc-gemini.c                     |  8 ++---
> >  drivers/rtc/rtc-imxdi.c                      | 16 +++++-----
> >  drivers/rtc/rtc-jz4740.c                     | 12 ++++----
> >  drivers/rtc/rtc-lpc32xx.c                    | 19 +++++-------
> >  drivers/rtc/rtc-mv.c                         |  2 +-
> >  drivers/rtc/rtc-omap.c                       |  6 ++--
> >  drivers/rtc/rtc-pcap.c                       | 16 +++++-----
> >  drivers/rtc/rtc-pl030.c                      | 24 +++++++--------
> >  drivers/rtc/rtc-pl031.c                      | 31 ++++++++-----------
> >  drivers/rtc/rtc-pm8xxx.c                     | 22 +++++++-------
> >  drivers/rtc/rtc-rs5c348.c                    |  4 +--
> >  drivers/rtc/rtc-sa1100.c                     | 25 +++++++---------
> >  drivers/rtc/rtc-sh.c                         |  2 +-
> >  drivers/rtc/rtc-sirfsoc.c                    | 18 +++++------
> >  drivers/rtc/rtc-snvs.c                       | 14 ++++-----
> >  drivers/rtc/rtc-stk17ta8.c                   |  2 +-
> >  drivers/rtc/rtc-stmp3xxx.c                   | 12 ++++----
> >  drivers/rtc/rtc-sun6i.c                      | 14 ++++-----
> >  drivers/rtc/rtc-sysfs.c                      | 25 ++++++++--------
> >  drivers/rtc/rtc-tegra.c                      | 22 +++++++-------
> >  drivers/rtc/rtc-test.c                       | 17 +----------
> >  drivers/rtc/rtc-tps6586x.c                   | 26 ++++++++--------
> >  drivers/rtc/rtc-vr41xx.c                     |  6 ++--
> >  drivers/rtc/rtc-wm831x.c                     | 28 +++++++----------
> >  drivers/rtc/rtc-xgene.c                      | 12 ++++----
> >  kernel/power/suspend_test.c                  |  6 ++--
> >  51 files changed, 342 insertions(+), 420 deletions(-)
> > 
> > -- 
> > CC: adi-buildroot-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
> > CC: Alessandro Zummo <a.zummo-BfzFCNDTiLLj+vYz1yj4TQ@public.gmane.org>
> > CC: Alexandre Belloni <alexandre.belloni-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>
> > CC: Gregory Clement <gregory.clement-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>
> > CC: Ingo Molnar <mingo-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
> > CC: Jason Cooper <jason-NLaQJdtUoK4Be96aLqz0jA@public.gmane.org>
> > CC: John Stultz <john.stultz-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
> > CC: linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
> > CC: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> > CC: Linus Walleij <linus.walleij-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
> > CC: Michael Chan <michael.chan-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
> > CC: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> > CC: rtc-linux-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
> > CC: Sebastian Hesselbarth <sebastian.hesselbarth-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> > CC: Support Opensource <support.opensource-WBD+wuPFNBhBDgjK7y7TUQ@public.gmane.org>
> > CC: Thomas Gleixner <tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org>
> > CC: x86-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org
> > CC: Baruch Siach <baruch-NswTu9S1W3P6gbPvEgmw2w@public.gmane.org>
> > CC: Hans Ulli Kroll <ulli.kroll-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org>
> > CC: Vladimir Zapolskiy <vz-ChpfBGZJDbMAvxtiuMwx3w@public.gmane.org>
> > CC: Sylvain Lemieux <slemieux.tyco-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> > CC: Barry Song <baohua-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
> > CC: Maxime Ripard <maxime.ripard-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>
> > CC: Chen-Yu Tsai <wens-jdAy2FN1RRM@public.gmane.org>
> > CC: Thierry Reding <thierry.reding-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> > CC: Jonathan Hunter <jonathanh-DDmLM1+adcrQT0dZR+AlfA@public.gmane.org>
> > CC: linux-tegra-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> > CC: patches-yzvPICuk2AATkU/dhu1WVueM+bqZidxxQQ4Iyu8u01E@public.gmane.org
> > CC: "Rafael J. Wysocki" <rjw-LthD3rsA81gm4RdzfppkhA@public.gmane.org>
> > CC: Pavel Machek <pavel-+ZI9xUNit7I@public.gmane.org>
> > CC: Len Brown <len.brown-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
> > CC: linux-pm-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> > 
> > 1.9.1
> > 
> 
> -- 
> Alexandre Belloni, Free Electrons
> Embedded Linux and Kernel engineering
> http://free-electrons.com

-- 
Alexandre Belloni, Free Electrons
Embedded Linux and Kernel engineering
http://free-electrons.com

-- 
You received this message because you are subscribed to "rtc-linux".
Membership options at http://groups.google.com/group/rtc-linux .
Please read http://groups.google.com/group/rtc-linux/web/checklist
before submitting a driver.
--- 
You received this message because you are subscribed to the Google Groups "rtc-linux" group.
To unsubscribe from this group and stop receiving emails from it, send an email to rtc-linux+unsubscribe-/JYPxA39Uh5TLH3MbocFF+G/Ez6ZCGd0@public.gmane.org
For more options, visit https://groups.google.com/d/optout.
