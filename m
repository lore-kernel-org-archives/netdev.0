From: Russell King - ARM Linux <linux-I+IVW8TIWO2tmTQ+vhA3Yw@public.gmane.org>
Subject: Re: [PATCH 00/51] rtc: stop using rtc deprecated functions
Date: Tue, 20 Jun 2017 23:38:59 +0100
Message-ID: <20170620223859.GO4902@n2100.armlinux.org.uk>
References: <20170620213507.urobmtg34vzubrdq@piout.net>
 <alpine.DEB.2.20.1706202343120.2157@nanos>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alexandre Belloni <alexandre.belloni-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>,
        Benjamin Gaignard <benjamin.gaignard-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>,
        Baruch Siach <baruch-NswTu9S1W3P6gbPvEgmw2w@public.gmane.org>,
        "patches-yzvPICuk2AATkU/dhu1WVueM+bqZidxxQQ4Iyu8u01E@public.gmane.org"
        <patches-yzvPICuk2AATkU/dhu1WVueM+bqZidxxQQ4Iyu8u01E@public.gmane.org>,
        Linus Walleij <linus.walleij-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>,
        "linux-tegra-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-tegra-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Thierry Reding <thierry.reding-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        Pavel Machek <pavel-+ZI9xUNit7I@public.gmane.org>, "x86-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org" <x86-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Jonathan Hunter <jonathanh-DDmLM1+adcrQT0dZR+AlfA@public.gmane.org>,
        Chen-Yu Tsai <wens-jdAy2FN1RRM@public.gmane.org>, Ingo Molnar <mingo-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
        Sylvain Lemieux <slemieux.tyco-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        Sebastian Hesselbarth <sebastian.hesselbarth-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        Len Brown <len.brown-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
        "linaro-kernel-cunTk1MwBs8s++Sfvej+rw@public.gmane.org" <linaro-kernel-cunTk1MwBs8s++Sfvej+rw@public.gmane.org>,
        Jason Cooper <jason-NLaQJdtUoK4Be96aLqz0jA@public.gmane.org>,
To: Thomas Gleixner <tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org>
Return-path: <linux-tegra-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.20.1706202343120.2157@nanos>
Sender: linux-tegra-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, Jun 21, 2017 at 12:00:30AM +0200, Thomas Gleixner wrote:
> Yes, but there are still quite some issues to solve there:
> 
>      1) How do you tell the system that it should apply the offset in the
>      	first place, i.e at boot time before NTP or any other mechanism can
>      	correct it?
> 
>      2) Deal with creative vendors who have their own idea about the 'start
>      	of the epoch'
> 	
>      3) Add the information of wraparound time to the rtc device which
>      	needs to be filled in for each device. That way the rtc_***
>      	accessor functions can deal with them whether they wrap in 2038 or
>      	2100 or whatever.
> 
> #3 is the simplest problem of them :)	

Well, if there's additional non-volatile storage, you can store
additional information in there, but you still need the RTC
subsystem to be aware that the hardware is only 32-bit capable.

You'd also still need something along the lines I detailed
(redefining what dates the past 32-bit values indicate) to cope
with the RTC being set backwards after the machine thinks (possibly
incorrectly) that the date has jumped forwards.

-- 
RMK's Patch system: http://www.armlinux.org.uk/developer/patches/
FTTC broadband for 0.8mile line: currently at 9.6Mbps down 400kbps up
according to speedtest.net.
