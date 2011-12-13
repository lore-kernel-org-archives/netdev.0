From: Eugene <elubarsky@gmail.com>
Subject: Re: drivers/net/usb/asix: bug in asix_get_wol
Date: Wed, 14 Dec 2011 00:03:43 +1100
Message-ID: <CAKbEaOBnGAJuZiM5BRaR3RD6EzgB-mCVrC0v2AbnniFpx22m8A@mail.gmail.com>
References: <CAKbEaOBODRW1pL4OiwZTKOfqtPEhEOHBBwXQNWVoBh9zzLX9kQ@mail.gmail.com>
	<CANEJEGud6++PGHRZGt1xMonX1XvxeU19Wd3YNsbgLQG+uQi47g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Freddy Xin <freddy@asix.com.tw>,
	Allan Chou <allan@asix.com.tw>
To: Grant Grundler <grundler@chromium.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:38043 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751037Ab1LMNDo convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Dec 2011 08:03:44 -0500
Received: by bkcjm19 with SMTP id jm19so2749247bkc.19
        for <netdev@vger.kernel.org>; Tue, 13 Dec 2011 05:03:43 -0800 (PST)
In-Reply-To: <CANEJEGud6++PGHRZGt1xMonX1XvxeU19Wd3YNsbgLQG+uQi47g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Grant,


The problem is that, as it's currently written, asix_get_wol always
returns that wake-on-lan is disabled.


Cheers,
Eugene

On 12 December 2011 10:29, Grant Grundler <grundler@chromium.org> wrote=
:
> [+freddy/allan @ ASIX]
>
> On Sat, Dec 10, 2011 at 5:02 PM, Eugene <elubarsky@gmail.com> wrote:
>> Dear kernel devs,
>>
>> Thanks for the commit at
>> http://git.kernel.org/?p=3Dlinux/kernel/git/next/linux-next.git;a=3D=
commitdiff;h=3D4ad1438f025ed8d1e4e95a796ca7f0ad5a22c378,
>> It successfully stops my adapter from dying when wake-on-lan gets
>> enabled.
>
> Hi Eugene!
> thanks for the "it works!" report.
>
>> However, I've noticed that it has broken asix_get_wol - the
>> lines
>>
>> =A0 =A0 =A0 if (opt & AX_MONITOR_LINK)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 wolinfo->wolopts |=3D WAKE_PHY;
>> =A0 =A0 =A0 if (opt & AX_MONITOR_MAGIC)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 wolinfo->wolopts |=3D WAKE_MAGIC;
>>
>> have been accidentally removed.
>
> This wasn't by accident. This comment in the commit log perhaps
> doesn't explain sufficiently:
> | =A0 =A0Remove MONITOR_MODE. In this mode, Received packets are not =
buffered when
> | the remote wakeup is enabled.
>
>> The vendor driver has them, and I've
>> successfully tested a kernel with these lines included. The change i=
s
>> too small for me to bother sending in a properly formatted patch...
>
> "Too small"? No such thing. :)
>
> cheers,
> grant
