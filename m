From: Nathan Royce <nroycea+kernel@gmail.com>
Subject: Re: ath9k_htc - Division by zero in kernel (as well as firmware panic)
Date: Sat, 3 Jun 2017 03:19:10 -0500
Message-ID: <CALaQ_hphMsG9MRanAMmTunxwqnWi0U+EfNUgxpaTHxVX4BccVA@mail.gmail.com>
References: <CALaQ_hrrcu7KebkwLE7xABEgiTwyvcmKb+tUfhG3bRf+kRz7RQ@mail.gmail.com>
 <71818afe-9075-5582-bb6c-650dfa8a5363@rempel-privat.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: QCA ath9k Development <ath9k-devel@qca.qualcomm.com>,
        Kalle Valo <kvalo@codeaurora.org>,
        linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org,
        ath9k_htc_fw <ath9k_htc_fw@lists.infradead.org>
To: Oleksij Rempel <linux@rempel-privat.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <71818afe-9075-5582-bb6c-650dfa8a5363@rempel-privat.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Jun 3, 2017 at 2:57 AM, Oleksij Rempel <linux@rempel-privat.de> wrote:
> Hm... this function and file:
> linux/drivers/net/wireless/ath/ath9k/common-beacon.c
> didn't changed since 2015. So, it should be some thing different.
> Can you run
> git bisect to find exact patch caused this regression?
>
That was the first time I experienced the x/0 issue and don't know how
I'd reproduce it.

> Yes, this is "normal" problem. The firmware has no error handler for PCI
> bus related exceptions. So if we filed to read PCI bus first time, we
> have choice to Ooops and stall or Ooops and reboot ASAP. So we reboot
> and provide an kernel "firmware panic!" message.
> Every one who can or will to fix this, is welcome.
>
Thanks for that explanation. I'm not sure it's something I could
tackle though. My best bet in the meantime is to coax systemd to
restart the services when the device pops up. However, every attempt
has failed so far.

> It is possible. If adapter is used in AP mode, then lots of WiFi noise
> is dumped over this interface. I assume the reproducibility depends on
> external environment, not internal.
>
I find this quite believable. I have 2.4ghz happening with the
TP-Link, ZTE Mobley, bluetooth, logitech unifying, usb 3.0. Though all
4 devices are going through the USB 2.0 port, and the tp-link and
mobley have long usb cables in the attic and the hub connects through
a 2m usb extension. So yeah, I've got a lot of variables in play.
