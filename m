From: Ulf Hansson <ulf.hansson@linaro.org>
Subject: Re: [PATCH] net: smsc911x: Synchronize the runtime PM status during
 system suspend
Date: Wed, 2 Nov 2016 00:53:42 +0100
Message-ID: <CAPDyKFpVmqNcPPsdSyFU4ZRh4TNHtKhiAEW6TCbf-LU7+3odrQ@mail.gmail.com>
References: <1477567434-5128-1-git-send-email-ulf.hansson@linaro.org>
 <CAMuHMdUbU07t2kB6J0rSOiOTbDkegP73FAAEenViuDjQUFE-Jg@mail.gmail.com>
 <CAPDyKFprWcita5sbdwTqbdi2CMW4gx7_UB7+kMd9R2rqXdcALQ@mail.gmail.com> <3305877.UjuP622RYi@vostro.rjw.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Geert Uytterhoeven <geert@linux-m68k.org>,
        Alan Stern <stern@rowland.harvard.edu>,
        Linux PM list <linux-pm@vger.kernel.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Len Brown <len.brown@intel.com>, Pavel Machek <pavel@ucw.cz>,
        Kevin Hilman <khilman@kernel.org>,
        Lina Iyer <lina.iyer@linaro.org>,
        Jon Hunter <jonathanh@nvidia.com>,
        Marek Szyprowski <m.szyprowski@samsung.com>,
        Linus Walleij <linus.walleij@linaro.org>,
        Steve Glendinning <steve.glendinning@shawell.net>
To: "Rafael J. Wysocki" <rjw@rjwysocki.net>
Return-path: <linux-pm-owner@vger.kernel.org>
In-Reply-To: <3305877.UjuP622RYi@vostro.rjw.lan>
Sender: linux-pm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 1 November 2016 at 05:19, Rafael J. Wysocki <rjw@rjwysocki.net> wrote:
> On Thursday, October 27, 2016 01:53:03 PM Ulf Hansson wrote:
>> On 27 October 2016 at 13:41, Geert Uytterhoeven <geert@linux-m68k.org> wrote:
>> > Hi Ulf,
>> >
>> > On Thu, Oct 27, 2016 at 1:23 PM, Ulf Hansson <ulf.hansson@linaro.org> wrote:
>> >> The smsc911c driver puts its device into low power state when entering
>> >> system suspend. Although it doesn't update the device's runtime PM status
>> >> to RPM_SUSPENDED, which causes problems for a parent device.
>> >>
>> >> In particular, when the runtime PM status of the parent is requested to be
>> >> updated to RPM_SUSPENDED, the runtime PM core prevent this, because it's
>> >> forbidden to runtime suspend a device, which has an active child.
>> >>
>> >> Fix this by updating the runtime PM status of the smsc911x device to
>> >> RPM_SUSPENDED during system suspend. In system resume, let's reverse that
>> >> action by runtime resuming the device and thus also the parent.
>> >
>> > Thanks for your patch!
>> >
>> > The changelog sounds quite innocent, but this does fix a system crash
>> > during resume from s2ram.
>> >
>> >> Signed-off-by: Ulf Hansson <ulf.hansson@linaro.org>
>> >> Tested-by: Geert Uytterhoeven <geert+renesas@glider.be>
>> >> Cc: Steve Glendinning <steve.glendinning@shawell.net>
>> >> Fixes: 8b1107b85efd ("PM / Runtime: Don't allow to suspend a device with an active child")
>> >
>> > While the abovementioned commit made the problem visible, the root cause
>> > was present before, right?
>>
>> Yes.
>>
>> >
>> >> ---
>> >>
>> >> Note that the commit this change fixes is currently queued for 4.10 via
>> >> Rafael's linux-pm tree. So this fix should go via that tree as well.
>> >
>> > Alternatively, this could go in in v4.9 to avoid the problem from ever
>> > appearing in upstream?
>>
>> Makes perfect sense! In that case we should remove the fixes tag.
>>
>> Rafael, can you pick this up for 4.9 rc[n]?
>
> If that is to go into 4.9-rc, it really should go in via the networking tree,
> because there is no PM dependency for it as of today.
>
> I can rearrange my 4.10 queue to put this one before the runtime PM commit
> exposing the problem in smsc911x, though.

As we spoked at LPC today, I don't mind if you take care of this
through your tree.

Kind regards
Uffe
