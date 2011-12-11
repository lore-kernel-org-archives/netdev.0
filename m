From: Grant Grundler <grundler@chromium.org>
Subject: Re: drivers/net/usb/asix: bug in asix_get_wol
Date: Sun, 11 Dec 2011 15:29:38 -0800
Message-ID: <CANEJEGud6++PGHRZGt1xMonX1XvxeU19Wd3YNsbgLQG+uQi47g@mail.gmail.com>
References: <CAKbEaOBODRW1pL4OiwZTKOfqtPEhEOHBBwXQNWVoBh9zzLX9kQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Freddy Xin <freddy@asix.com.tw>,
	Allan Chou <allan@asix.com.tw>
To: Eugene <elubarsky@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gx0-f174.google.com ([209.85.161.174]:57812 "EHLO
	mail-gx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752402Ab1LKX3j convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 11 Dec 2011 18:29:39 -0500
Received: by ggdk6 with SMTP id k6so435061ggd.19
        for <netdev@vger.kernel.org>; Sun, 11 Dec 2011 15:29:39 -0800 (PST)
In-Reply-To: <CAKbEaOBODRW1pL4OiwZTKOfqtPEhEOHBBwXQNWVoBh9zzLX9kQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[+freddy/allan @ ASIX]

On Sat, Dec 10, 2011 at 5:02 PM, Eugene <elubarsky@gmail.com> wrote:
> Dear kernel devs,
>
> Thanks for the commit at
> http://git.kernel.org/?p=3Dlinux/kernel/git/next/linux-next.git;a=3Dc=
ommitdiff;h=3D4ad1438f025ed8d1e4e95a796ca7f0ad5a22c378,
> It successfully stops my adapter from dying when wake-on-lan gets
> enabled.

Hi Eugene!
thanks for the "it works!" report.

> However, I've noticed that it has broken asix_get_wol - the
> lines
>
> =C2=A0 =C2=A0 =C2=A0 if (opt & AX_MONITOR_LINK)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 wolinfo->wolopts |=3D=
 WAKE_PHY;
> =C2=A0 =C2=A0 =C2=A0 if (opt & AX_MONITOR_MAGIC)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 wolinfo->wolopts |=3D=
 WAKE_MAGIC;
>
> have been accidentally removed.

This wasn't by accident. This comment in the commit log perhaps
doesn't explain sufficiently:
|    Remove MONITOR_MODE. In this mode, Received packets are not buffer=
ed when
| the remote wakeup is enabled.

> The vendor driver has them, and I've
> successfully tested a kernel with these lines included. The change is
> too small for me to bother sending in a properly formatted patch...

"Too small"? No such thing. :)

cheers,
grant
