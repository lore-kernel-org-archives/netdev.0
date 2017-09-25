From: Grant Grundler <grundler@chromium.org>
Subject: Re: [PATCH] r8152: add Linksys USB3GIGV1 id
Date: Mon, 25 Sep 2017 13:17:32 -0700
Message-ID: <CANEJEGtM+gFC9Ofmp=UmGn5pKys9NRbsC6+ks_VqaLKWkEBS8A@mail.gmail.com>
References: <20170922190604.108155-1-grundler@chromium.org> <1506351074.7827.13.camel@suse.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Grant Grundler <grundler@chromium.org>,
        Hayes Wang <hayeswang@realtek.com>,
        "David S . Miller" <davem@davemloft.net>,
        LKML <linux-kernel@vger.kernel.org>,
        linux-usb <linux-usb@vger.kernel.org>,
        netdev <netdev@vger.kernel.org>
To: Oliver Neukum <oneukum@suse.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f181.google.com ([209.85.161.181]:52451 "EHLO
        mail-yw0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S935358AbdIYURe (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 25 Sep 2017 16:17:34 -0400
Received: by mail-yw0-f181.google.com with SMTP id i6so5608625ywc.9
        for <netdev@vger.kernel.org>; Mon, 25 Sep 2017 13:17:34 -0700 (PDT)
In-Reply-To: <1506351074.7827.13.camel@suse.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[grrhmail...sorry! resending as plain text]

Hallo Oliver!

On Mon, Sep 25, 2017 at 7:51 AM, Oliver Neukum <oneukum@suse.com> wrote:
> Am Freitag, den 22.09.2017, 12:06 -0700 schrieb Grant Grundler:
> > This Linksys dongle by default comes up in cdc_ether mode.
> > This patch allows r8152 to claim the device:
> >    Bus 002 Device 002: ID 13b1:0041 Linksys
>
> Hi,
>
> have you tested this in case cdc_ether is for some reason already
> loaded?

I did not consider testing this case since it's not possible on a
normal chromeos system (the entire root file system is signed for
normal users and get's rebooted after an update).  I could test this
in developer mode of course.

Did you expect both driver probe routines to claim the device and
wreak havoc with the device?

> The patch seems to enable r8152 but does not disable cdc_ether.

Correct. r8152 happens to claim the device before cdc_ether does - I
thought because cdc_ether is a class driver and only gets picked up
after vendor specific drivers are probed.  Is that correct?

I didn't realize cdc_ether has a blacklist to make sure
RTL8152|RTL8153 devices are not picked up by cdc_ether. Would you
prefer I add this device to the blacklist in the same patch?

cheers,
grant

>
>         Regards
>                 Oliver
>
