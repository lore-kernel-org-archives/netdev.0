From: Russell King - ARM Linux <linux-I+IVW8TIWO2tmTQ+vhA3Yw@public.gmane.org>
Subject: Re: [PATCH 00/51] rtc: stop using rtc deprecated functions
Date: Wed, 21 Jun 2017 10:35:49 +0100
Message-ID: <20170621093549.GQ4902@n2100.armlinux.org.uk>
References: <20170620100348.zh4ygvjjgnhxvmvl@piout.net>
 <20170620121011.GA13221@amd>
 <20170620122400.sm7qqvwyj6cuzarw@piout.net>
 <20170620132620.GA16881@amd>
 <6ED8E3B22081A4459DAC7699F3695FB7018CD96FCD@SW-EX-MBX02.diasemi.com>
 <20170620134458.GA10104@amd>
 <20170620134827.ubvzhh25klaotupv@piout.net>
 <CA+M3ks68+z6nDtYM8CDpso7SxjB6Nt5E=rOc1yxx=kDz6PUeVQ@mail.gmail.com>
 <20170620211536.GM4902@n2100.armlinux.org.uk>
 <063D6719AE5E284EB5DD2968C1650D6DD00278C0@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Benjamin Gaignard <benjamin.gaignard-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>,
        Alexandre Belloni <alexandre.belloni-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>,
        Baruch Siach <baruch-NswTu9S1W3P6gbPvEgmw2w@public.gmane.org>,
        "patches-yzvPICuk2AATkU/dhu1WVueM+bqZidxxQQ4Iyu8u01E@public.gmane.org"
        <patches-yzvPICuk2AATkU/dhu1WVueM+bqZidxxQQ4Iyu8u01E@public.gmane.org>,
        Linus Walleij <linus.walleij-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>,
        "linux-tegra-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-tegra-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Thierry Reding <thierry.reding-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        Pavel Machek <pavel-+ZI9xUNit7I@public.gmane.org>,
        Thomas Gleixner <tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org>,
        "x86-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org" <x86-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Jonathan Hunter <jonathanh-DDmLM1+adcrQT0dZR+AlfA@public.gmane.org>,
        Chen-Yu Tsai <wens-jdAy2FN1RRM@public.gmane.org>, Ingo Molnar <mingo-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
        Sylvain Lemieux <slemieux.tyco-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        Sebastian Hesselbarth <sebastian.hesselbarth-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        Len Brown <len.brown-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
        "linaro-kernel-cunTk1MwBs8s++Sfvej+rw@public.gmane.org" <linaro-kernel-cunTk1MwBs8s++Sfvej+rw@public.gmane.org>
To: David Laight <David.Laight-ZS65k/vG3HxXrIkS9f7CXA@public.gmane.org>
Return-path: <linux-tegra-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6DD00278C0-VkEWCZq2GCInGFn1LkZF6NBPR1lH4CV8@public.gmane.org>
Sender: linux-tegra-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, Jun 21, 2017 at 09:26:51AM +0000, David Laight wrote:
> From: Russell King - ARM Linux
> > Sent: 20 June 2017 22:16
> ..
> > Consider that at the moment, we define the 32-bit RTC representation to
> > start at a well known epoch.  We _could_ decide that when it wraps to
> > 0x80000000 seconds, we'll define the lower 0x40000000 seconds to mean
> > dates in the future - and keep rolling that forward each time we cross
> > another 0x40000000 seconds.  Unless someone invents a real time machine,
> > we shouldn't need to set a modern RTC back to 1970.
> 
> True, just treating the value as unsigned gives another 67 years.

We _already_ do treat it as an unsigned number, so already the panicing
about 2038 is complete and utter nonsense - that's why I've been
consistently stating the 2106 date.

> If a 32bit RTC is programmed with the low 32bits of the 64bit 'seconds
> since 1970' the kernel should have no real difficulty sorting out the
> high bits from other available information.

Right, but converting all the 32-bit conversion functions to 64-bit
means that rather than "sorting out" that from the core RTC driver,
we have to implement solutions in each and every driver.

While that may appear to be a good idea, many RTCs that are 32-bit
counters do not themselves have additional non-volatile storage, so
it means that we're ending up with a lot of RTC specific hacks to
go and get the additional information from some other driver elsewhere
in the system.

> Problems with things like the x86 bios setting the rtc to stupid values
> are another matter.

Forget x86, the RTC there does not store time as a 32-bit integer, it's
stored as its component values, and there's non-volatile memory attached
to the RTC.  Hence, it's out of scope of "what to do about RTCs that
store time in 32-bit format" and also out of scope of "what to do about
RTC drivers that use the 32-bit time conversion function."

-- 
RMK's Patch system: http://www.armlinux.org.uk/developer/patches/
FTTC broadband for 0.8mile line: currently at 9.6Mbps down 400kbps up
according to speedtest.net.
