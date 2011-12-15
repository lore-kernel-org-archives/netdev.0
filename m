From: Grant Grundler <grundler@chromium.org>
Subject: Re: drivers/net/usb/asix: bug in asix_get_wol
Date: Thu, 15 Dec 2011 08:48:20 -0800
Message-ID: <CANEJEGvz2ZHD_ZNJm_WeKCdVE9pmSQJY5dCe8hNayAS0MFN=-Q@mail.gmail.com>
References: <CAKbEaOBODRW1pL4OiwZTKOfqtPEhEOHBBwXQNWVoBh9zzLX9kQ@mail.gmail.com>
	<CANEJEGud6++PGHRZGt1xMonX1XvxeU19Wd3YNsbgLQG+uQi47g@mail.gmail.com>
	<CAKbEaOBnGAJuZiM5BRaR3RD6EzgB-mCVrC0v2AbnniFpx22m8A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Freddy Xin <freddy@asix.com.tw>
To: Eugene <elubarsky@gmail.com>, Allan Chou <allan@asix.com.tw>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gx0-f174.google.com ([209.85.161.174]:42617 "EHLO
	mail-gx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932635Ab1LOQsV convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Dec 2011 11:48:21 -0500
Received: by ggdk6 with SMTP id k6so1953022ggd.19
        for <netdev@vger.kernel.org>; Thu, 15 Dec 2011 08:48:20 -0800 (PST)
In-Reply-To: <CAKbEaOBnGAJuZiM5BRaR3RD6EzgB-mCVrC0v2AbnniFpx22m8A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 13, 2011 at 5:03 AM, Eugene <elubarsky@gmail.com> wrote:
> Hi Grant,
>
>
> The problem is that, as it's currently written, asix_get_wol always
> returns that wake-on-lan is disabled.

I think that was the intent.

Allan, can you please confirm?

thanks,
grant

>
>
> Cheers,
> Eugene
>
> On 12 December 2011 10:29, Grant Grundler <grundler@chromium.org> wro=
te:
>> [+freddy/allan @ ASIX]
>>
>> On Sat, Dec 10, 2011 at 5:02 PM, Eugene <elubarsky@gmail.com> wrote:
>>> Dear kernel devs,
>>>
>>> Thanks for the commit at
>>> http://git.kernel.org/?p=3Dlinux/kernel/git/next/linux-next.git;a=3D=
commitdiff;h=3D4ad1438f025ed8d1e4e95a796ca7f0ad5a22c378,
>>> It successfully stops my adapter from dying when wake-on-lan gets
>>> enabled.
>>
>> Hi Eugene!
>> thanks for the "it works!" report.
>>
>>> However, I've noticed that it has broken asix_get_wol - the
>>> lines
>>>
>>> =C2=A0 =C2=A0 =C2=A0 if (opt & AX_MONITOR_LINK)
>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 wolinfo->wolopts |=
=3D WAKE_PHY;
>>> =C2=A0 =C2=A0 =C2=A0 if (opt & AX_MONITOR_MAGIC)
>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 wolinfo->wolopts |=
=3D WAKE_MAGIC;
>>>
>>> have been accidentally removed.
>>
>> This wasn't by accident. This comment in the commit log perhaps
>> doesn't explain sufficiently:
>> | =C2=A0 =C2=A0Remove MONITOR_MODE. In this mode, Received packets a=
re not buffered when
>> | the remote wakeup is enabled.
>>
>>> The vendor driver has them, and I've
>>> successfully tested a kernel with these lines included. The change =
is
>>> too small for me to bother sending in a properly formatted patch...
>>
>> "Too small"? No such thing. :)
>>
>> cheers,
>> grant
