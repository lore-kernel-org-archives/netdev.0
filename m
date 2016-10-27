From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: Re: [PATCH] net: smsc911x: Synchronize the runtime PM status during
 system suspend
Date: Thu, 27 Oct 2016 13:41:14 +0200
Message-ID: <CAMuHMdUbU07t2kB6J0rSOiOTbDkegP73FAAEenViuDjQUFE-Jg@mail.gmail.com>
References: <1477567434-5128-1-git-send-email-ulf.hansson@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "Rafael J. Wysocki" <rjw@rjwysocki.net>,
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
To: Ulf Hansson <ulf.hansson@linaro.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f177.google.com ([209.85.220.177]:35414 "EHLO
        mail-qk0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1034057AbcJ0OwV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 27 Oct 2016 10:52:21 -0400
In-Reply-To: <1477567434-5128-1-git-send-email-ulf.hansson@linaro.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Ulf,

On Thu, Oct 27, 2016 at 1:23 PM, Ulf Hansson <ulf.hansson@linaro.org> wrote:
> The smsc911c driver puts its device into low power state when entering
> system suspend. Although it doesn't update the device's runtime PM status
> to RPM_SUSPENDED, which causes problems for a parent device.
>
> In particular, when the runtime PM status of the parent is requested to be
> updated to RPM_SUSPENDED, the runtime PM core prevent this, because it's
> forbidden to runtime suspend a device, which has an active child.
>
> Fix this by updating the runtime PM status of the smsc911x device to
> RPM_SUSPENDED during system suspend. In system resume, let's reverse that
> action by runtime resuming the device and thus also the parent.

Thanks for your patch!

The changelog sounds quite innocent, but this does fix a system crash
during resume from s2ram.

> Signed-off-by: Ulf Hansson <ulf.hansson@linaro.org>
> Tested-by: Geert Uytterhoeven <geert+renesas@glider.be>
> Cc: Steve Glendinning <steve.glendinning@shawell.net>
> Fixes: 8b1107b85efd ("PM / Runtime: Don't allow to suspend a device with an active child")

While the abovementioned commit made the problem visible, the root cause
was present before, right?

> ---
>
> Note that the commit this change fixes is currently queued for 4.10 via
> Rafael's linux-pm tree. So this fix should go via that tree as well.

Alternatively, this could go in in v4.9 to avoid the problem from ever
appearing in upstream?

Gr{oetje,eeting}s,

                        Geert
