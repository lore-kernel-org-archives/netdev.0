From: Thomas Gleixner <tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org>
Subject: Re: [PATCH 00/51] rtc: stop using rtc deprecated functions
Date: Wed, 21 Jun 2017 00:00:30 +0200 (CEST)
Message-ID: <alpine.DEB.2.20.1706202343120.2157@nanos>
References: <20170620213507.urobmtg34vzubrdq@piout.net>
Reply-To: rtc-linux-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Russell King - ARM Linux <linux-I+IVW8TIWO2tmTQ+vhA3Yw@public.gmane.org>,
    Benjamin Gaignard <benjamin.gaignard-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>,
    Baruch Siach <baruch-NswTu9S1W3P6gbPvEgmw2w@public.gmane.org>,
    "patches-yzvPICuk2AATkU/dhu1WVueM+bqZidxxQQ4Iyu8u01E@public.gmane.org" <patches-yzvPICuk2AATkU/dhu1WVueM+bqZidxxQQ4Iyu8u01E@public.gmane.org>,
    Linus Walleij <linus.walleij-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>,
    "linux-tegra-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-tegra-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
    Thierry Reding <thierry.reding-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Pavel Machek <pavel-+ZI9xUNit7I@public.gmane.org>,
    "x86-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org" <x86-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Jonathan Hunter <jonathanh-DDmLM1+adcrQT0dZR+AlfA@public.gmane.org>,
    Chen-Yu Tsai <wens-jdAy2FN1RRM@public.gmane.org>, Ingo Molnar <mingo-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
    Sylvain Lemieux <slemieux.tyco-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
    Sebastian Hesselbarth <sebastian.hesselbarth-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
    Len Brown <len.brown-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
    "linaro-kernel-cunTk1MwBs8s++Sfvej+rw@public.gmane.org" <linaro-kernel-cunTk1MwBs8s++Sfvej+rw@public.gmane.org>,
    Jason Cooper <jason-NLaQJdtUoK4Be96aLqz0jA@public.gmane.org>,
    "rtc-linux-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org" <rtc-linux-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>,
    "l
To: Alexandre Belloni <alexandre.belloni-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>
Return-path: <rtc-linux+bncBDAMN6NI5EERBGNWU3FAKGQE5JILZ7Q-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
Sender: rtc-linux-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
In-Reply-To: <20170620213507.urobmtg34vzubrdq-m++hUPXGwpdeoWH0uzbU5w@public.gmane.org>
List-Post: <https://groups.google.com/group/rtc-linux/post>, <mailto:rtc-linux-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Help: <https://groups.google.com/support/>, <mailto:rtc-linux+help-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Archive: <https://groups.google.com/group/rtc-linux
List-Subscribe: <https://groups.google.com/group/rtc-linux/subscribe>, <mailto:rtc-linux+subscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Unsubscribe: <mailto:googlegroups-manage+712029733259+unsubscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>,
 <https://groups.google.com/group/rtc-linux/subscribe>
List-Id: netdev.vger.kernel.org

On Tue, 20 Jun 2017, Alexandre Belloni wrote:
> On 20/06/2017 at 22:15:36 +0100, Russell King - ARM Linux wrote:
> > On Tue, Jun 20, 2017 at 05:07:46PM +0200, Benjamin Gaignard wrote:
> > > 2017-06-20 15:48 GMT+02:00 Alexandre Belloni
> > > <alexandre.belloni-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>:
> > > >> Yes, that's argument against changing rtc _drivers_ for hardware that
> > > >> can not do better than 32bit. For generic code (such as 44/51 sysfs,
> > > >> 51/51 suspend test), the change still makes sense.
> > > 
> > > What I had in mind when writing those patches was to remove the limitations
> > > coming from those functions usage, even more since they been marked has
> > > deprecated.
> > 
> > I'd say that they should not be marked as deprecated.  They're entirely
> > appropriate for use with hardware that only supports a 32-bit
> > representation of time.
> > 
> > It's entirely reasonable to fix the ones that use other representations
> > that exceed that, but for those which do not, we need to keep using the
> > 32-bit versions.  Doing so actually gives us _more_ flexibility in the
> > future.
> > 
> > Consider that at the moment, we define the 32-bit RTC representation to
> > start at a well known epoch.  We _could_ decide that when it wraps to
> > 0x80000000 seconds, we'll define the lower 0x40000000 seconds to mean
> > dates in the future - and keep rolling that forward each time we cross
> > another 0x40000000 seconds.  Unless someone invents a real time machine,
> > we shouldn't need to set a modern RTC back to 1970.
> > 
> 
> I agree with that but not the android guys. They seem to mandate an RTC
> that can store time from 01/01/1970. I don't know much more than that
> because they never cared to explain why that was actually necessary
> (apart from a laconic "this will result in a bad user experience")
> 
> I think tglx had a plan for offsetting the time at some point so 32-bit
> platform can pass 2038 properly.

Yes, but there are still quite some issues to solve there:

     1) How do you tell the system that it should apply the offset in the
     	first place, i.e at boot time before NTP or any other mechanism can
     	correct it?

     2) Deal with creative vendors who have their own idea about the 'start
     	of the epoch'
	
     3) Add the information of wraparound time to the rtc device which
     	needs to be filled in for each device. That way the rtc_***
     	accessor functions can deal with them whether they wrap in 2038 or
     	2100 or whatever.

#3 is the simplest problem of them :)	

> My opinion is that as long as userspace is not ready to handle those
> dates, it doesn't really matter because it is quite unlikely that
> anything will be able to continue running anyway.

That's a different story. Making the kernel y2038 ready in general is a
good thing. Whether userspace will be ready by then or not is completely
irrelevant.

Thanks,

	tglx


-- 
You received this message because you are subscribed to "rtc-linux".
Membership options at http://groups.google.com/group/rtc-linux .
Please read http://groups.google.com/group/rtc-linux/web/checklist
before submitting a driver.
--- 
You received this message because you are subscribed to the Google Groups "rtc-linux" group.
To unsubscribe from this group and stop receiving emails from it, send an email to rtc-linux+unsubscribe-/JYPxA39Uh5TLH3MbocFF+G/Ez6ZCGd0@public.gmane.org
For more options, visit https://groups.google.com/d/optout.
