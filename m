From: Alexandre Belloni <alexandre.belloni-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>
Subject: Re: [PATCH 00/51] rtc: stop using rtc deprecated functions
Date: Tue, 20 Jun 2017 15:48:27 +0200
Message-ID: <20170620134827.ubvzhh25klaotupv@piout.net>
References: <1497951359-13334-1-git-send-email-benjamin.gaignard@linaro.org>
 <20170620100348.zh4ygvjjgnhxvmvl@piout.net>
 <20170620121011.GA13221@amd>
 <20170620122400.sm7qqvwyj6cuzarw@piout.net>
 <20170620132620.GA16881@amd>
 <6ED8E3B22081A4459DAC7699F3695FB7018CD96FCD@SW-EX-MBX02.diasemi.com>
 <20170620134458.GA10104@amd>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Steve Twiss <stwiss.opensource-WBD+wuPFNBhBDgjK7y7TUQ@public.gmane.org>,
        Benjamin Gaignard <benjamin.gaignard-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>,
        "linaro-kernel-cunTk1MwBs8s++Sfvej+rw@public.gmane.org" <linaro-kernel-cunTk1MwBs8s++Sfvej+rw@public.gmane.org>,
        "adi-buildroot-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org"
        <adi-buildroot-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>,
        Alessandro Zummo <a.zummo-BfzFCNDTiLLj+vYz1yj4TQ@public.gmane.org>,
        Gregory Clement <gregory.clement-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>,
        Ingo Molnar <mingo-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
        Jason Cooper <jason-NLaQJdtUoK4Be96aLqz0jA@public.gmane.org>,
        John Stultz <john.stultz-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>,
        "linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org"
        <linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>,
        "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Linus Walleij <linus.walleij-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>,
        Michael Chan <michael.chan-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
        "netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "rtc-linux-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org" <rtc-li
To: Pavel Machek <pavel-+ZI9xUNit7I@public.gmane.org>
Return-path: <linux-tegra-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20170620134458.GA10104@amd>
Sender: linux-tegra-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 20/06/2017 at 15:44:58 +0200, Pavel Machek wrote:
> On Tue 2017-06-20 13:37:22, Steve Twiss wrote:
> > Hi Pavel,
> > 
> > On 20 June 2017 14:26, Pavel Machek wrote:
> > 
> > > Subject: Re: [PATCH 00/51] rtc: stop using rtc deprecated functions
> > > 
> > > On Tue 2017-06-20 14:24:00, Alexandre Belloni wrote:
> > > > On 20/06/2017 at 14:10:11 +0200, Pavel Machek wrote:
> > > > > On Tue 2017-06-20 12:03:48, Alexandre Belloni wrote:
> > > > > > On 20/06/2017 at 11:35:08 +0200, Benjamin Gaignard wrote:
> > > > > > > rtc_time_to_tm() and rtc_tm_to_time() are deprecated because they
> > > > > > > rely on 32bits variables and that will make rtc break in y2038/2016.
> > > > > >
> > > > > > Please don't, because this hide the fact that the hardware will not
> > > > > > handle dates in y2038 anyway and as pointed by Russell a few month ago,
> > > > > > rtc_time_to_tm will be able to catch it but the 64 bit version will
> > > > > > silently ignore it.
> > > > >
> > > > > Reference? Because rtc on PCs stores date in binary coded decimal, so
> > > > > it is likely to break in 2100, not 2038...
> > > >
> > > > I'm not saying it should be done but clearly, that is not the correct
> > > > thing to do for RTCs that are using a single 32 bits register to store
> > > > the time.
> > > > You give one example, I can give you three: armada38x, at91sam9,
> > > > at32ap700x and that just in the beginning of the series.
> > > 
> > > I wanted reference to Russell's mail.
> > 
> > This is it.
> > https://patchwork.kernel.org/patch/6219401/
> 
> Thanks.
> 
> Yes, that's argument against changing rtc _drivers_ for hardware that
> can not do better than 32bit. For generic code (such as 44/51 sysfs,
> 51/51 suspend test), the change still makes sense.
> 

Yes, we agree on that but I won't cherry pick working patches from a 51
patches series.


-- 
Alexandre Belloni, Free Electrons
Embedded Linux and Kernel engineering
http://free-electrons.com
