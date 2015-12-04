From: Aleksander Morgado <aleksander@aleksander.es>
Subject: Re: [PATCH 0/6] net: qmi_wwan: MDM9x30 support
Date: Fri, 4 Dec 2015 10:56:52 +0100
Message-ID: <CAAP7ucJmLg6eRRyJBZbEi9wJkfd84n2M=7EQp4rvObj+2bk1ng@mail.gmail.com>
References: <1449167063-22703-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	linux-usb@vger.kernel.org, Marcel Holtmann <marcel@holtmann.org>,
	Oliver Neukum <oneukum@suse.com>,
	Dan Williams <dcbw@redhat.com>
To: =?UTF-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f46.google.com ([209.85.218.46]:33083 "EHLO
	mail-oi0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752123AbbLDJ4w convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Dec 2015 04:56:52 -0500
Received: by oixx65 with SMTP id x65so65039781oix.0
        for <netdev@vger.kernel.org>; Fri, 04 Dec 2015 01:56:52 -0800 (PST)
In-Reply-To: <1449167063-22703-1-git-send-email-bjorn@mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 3, 2015 at 7:24 PM, Bj=C3=B8rn Mork <bjorn@mork.no> wrote:
> We add new device IDs all the time, often without any testing on
> actual hardware. This is usually OK as long as the device is similar
> to already supported devices, using the same chipset and firmware
> basis.  But the Sierra Wireless MC7455 is an example of a new chipset
> generation. Adding it based on assumed similarity with its ancestors
> proved too optimistic.
>
> This series adds the missing bits and pieces necessary to support LTE
> Advanced modems based on the Qualcomm MDM9x30 chipset. A big thanks t=
o
> Sierra Wireless for providing MC7455 samples for testing
>
> The most important change is the "raw-ip" support. The series also
> adds a necessary control request, removes an unsupported device ID,
> and adds a driver specific entry in MAINTAINERS.
>
> A few random notes about "raw-ip":
>
> "I rather have these all running in raw IP mode. The 802.3 framing is
> utterly stupid." - Marcel Holtmann in Jan 2012 [1]
>
> Marcel was right.  I should have listened to him. What more can I say=
?
>
> The 802.3 framing has provided a steady supply of firmware bugs for
> many years. We've added driver workarounds for many of these, but
> there are still known bugs where the workaround is so yucky that we
> have refused to apply it. But all that is over now.  The latest
> generation Qualcomm chips no longer supports 802.3 framing at all.
>
> I had two open questions regarding the "raw-ip" userspace API:
>
> 1) Should we continue faking an ethernet device, even if we don't use
>    the L2 headers on the USB link anymore?
>
>    There was a vote in favour of the "headerless" device. This is the
>    honest representation of the hardware/firmware interface.
>
> 2) What input should the driver base its framing on?
>
>    Snooping or directly manipulating QMI is considered out of the
>    question. We delegated all QMI handling to userspace from the
>    beginning.
>
>    We have so far required userspace to configure the firmware for
>    "802.3" framing, or fail if that proved impossible.  This
>    requirement is now changed.  Userspace must now inform the driver
>    if it negotiates "raw-ip" framing.  Two alternative interfaces wer=
e
>    proposed:
>     - ethtool private driver flag, or
>     - sysfs file
>
>    The NetworkManager/ModemManager developers were in favour of the
>    sysfs alternative.
>
> These questions (or any other you migh have :) are of course still
> open.  This patch set presents the solutions I currently prefer,
> considering the above.
>
> All comments are appreciated, even simple '+1' ones.
>

+1 from me as well.

We still need to decide how to manage this in userspace once the
kernel part is ready. For all pre-WDA devices, I'd use 802-3 as that
is what we've all been using. For WDA capable devices, we should
likely query what the current data link layer mode is, and ask the
kernel to use that one via sysfs; or, default to raw-ip in those,
don't know.

--=20
Aleksander
https://aleksander.es
