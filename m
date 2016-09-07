From: Linus Walleij <linus.walleij@linaro.org>
Subject: Re: [PATCH 3/3 v2] net: smsc911x: add wake-up event interrupt support
Date: Wed, 7 Sep 2016 15:51:05 +0200
Message-ID: <CACRpkdaf47wnY34BmbSqDskPPE2kSGpE641jakaya9J17g0qaQ@mail.gmail.com>
References: <1472043582-7653-1-git-send-email-linus.walleij@linaro.org>
 <1472043582-7653-3-git-send-email-linus.walleij@linaro.org> <dc552129-8631-e81d-fc3d-20d39ae10f11@arm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "David S . Miller" <davem@davemloft.net>,
        Steve Glendinning <steve.glendinning@smsc.com>,
        Guenter Roeck <linux@roeck-us.net>,
        Kamlakant Patel <kamlakant.patel@broadcom.com>,
        Pavel Fedin <p.fedin@samsung.com>,
        Sudeep Holla <sudeep.holla@arm.com>,
        Tony Lindgren <tony@atomide.com>,
        Florian Fainelli <f.fainelli@gmail.com>
To: Jeremy Linton <jeremy.linton@arm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f54.google.com ([209.85.218.54]:36129 "EHLO
        mail-oi0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933756AbcIGNvG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 7 Sep 2016 09:51:06 -0400
Received: by mail-oi0-f54.google.com with SMTP id w78so26139466oie.3
        for <netdev@vger.kernel.org>; Wed, 07 Sep 2016 06:51:06 -0700 (PDT)
In-Reply-To: <dc552129-8631-e81d-fc3d-20d39ae10f11@arm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 31, 2016 at 5:27 PM, Jeremy Linton <jeremy.linton@arm.com> wrote:

> The cleanup code in drv_remove seems to be missing, am I missing something?

No you're right it's just my bad coding. Fixing it and thanks for noticing.

> Also, do you want the wake-up to be active if the interface is downed?

Hm! Good point.

It seems most other drivers call
device_set_wakeup_enable() on the device inside a
foo_set_wol() (wake-on-LAN) from the
.set_wol() callback in struct ethtool_ops.

This is in response to the ethtool calls from userspace.

So we need to implement this too.

I don't know whether that has anything to do with whether
the interface is up or not, it seems orthogonal actually.

I will hold this patch back until I can investigate and test
and just resend patches 1+2 right now. (Bindings should
still be OK to merge I guess, and I think the RESET patch
is sorted out.)

Yours,
Linus Walleij
