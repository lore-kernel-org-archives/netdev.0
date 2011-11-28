From: =?UTF-8?B?0J/Qu9Cw0LzQtdC9INCf0LXRgtGA0L7Qsg==?=
	<plamen.sisi@gmail.com>
Subject: Re: [NET][TG3] Fwd: page allocation failure with linux 3.1.1
Date: Mon, 28 Nov 2011 09:16:26 +0200
Message-ID: <CALkh-Hi=Pb_cNUzHrJSe4o5-kmb+jLA8vpw8hiaGxROzNJ6oag@mail.gmail.com>
References: <CALkh-HhkzHb7-2LAwCNOZ-S4otfeM+tthyw2_XDbDUjFRSkKjA@mail.gmail.com>
	<CALkh-HiaDSJb7sStH=DHxXCmecFWYAC2q7hx72gGvFSYz+2r=A@mail.gmail.com>
	<1322462145.2826.6.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:45891 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751901Ab1K1HQ2 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Nov 2011 02:16:28 -0500
Received: by wwp14 with SMTP id 14so8492374wwp.1
        for <netdev@vger.kernel.org>; Sun, 27 Nov 2011 23:16:26 -0800 (PST)
In-Reply-To: <1322462145.2826.6.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2011/11/28 Eric Dumazet <eric.dumazet@gmail.com>:
> Le dimanche 27 novembre 2011 =C3=A0 22:34 +0200, =D0=9F=D0=BB=D0=B0=D0=
=BC=D0=B5=D0=BD =D0=9F=D0=B5=D1=82=D1=80=D0=BE=D0=B2 a =C3=A9crit :
>> Hello, David, Jarek and Eric!
>>
>> In September 2010 I had trouble with the Broadcom Tygon 3 network dr=
iver:
>>
>> http://git.kernel.org/?p=3Dlinux/kernel/git/torvalds/linux.git;a=3Dc=
ommitdiff;h=3D64289c8e6851bca0e589e064c9a5c9fbd6ae5dd4
>>
>> Please, see below my most recent findings, where again tg3 is presen=
t.
>>
>> I sent this earlier today to linux-kernel list. Sorry if this is not
>> related to the above, thus to the tg3 kernel driver.
>>
>> ---------- Forwarded message ----------
>> From: =D0=9F=D0=BB=D0=B0=D0=BC=D0=B5=D0=BD =D0=9F=D0=B5=D1=82=D1=80=D0=
=BE=D0=B2 <plamen.sisi@gmail.com>
>> Date: 2011/11/27
>> Subject: page allocation failure with linux 3.1.1
>> To: linux-kernel@vger.kernel.org
>>
>>
>> Hello, folks!
>>
>> Please, cc me, as I'm not subsribed to the list.
>>
>> With Linux 3.1.1 I'm hitting a page allocation failure on a machine
>> with 512 MB RAM and 2 GB swap, which looks like this:
>>
>> [388632.749423] swapper: page allocation failure: order:4, mode:0x40=
20
>> [388632.749431] Pid: 0, comm: swapper Not tainted 3.1.1-FS #1
>> [388632.749434] Call Trace:
>> [388632.749447] =C2=A0[<c106cd03>] ? warn_alloc_failed+0xab/0xd5
>> [388632.749454] =C2=A0[<c106f5f5>] ? __alloc_pages_nodemask+0x4ea/0x=
6aa
>> [388632.749460] =C2=A0[<c106f822>] ? __get_free_pages+0x14/0x32
>> [388632.749467] =C2=A0[<c12aecc7>] ? __alloc_skb+0x4c/0xe9
>> [388632.749472] =C2=A0[<c12b02cc>] ? skb_copy+0x2e/0x7a
>> [388632.749478] =C2=A0[<c122de36>] ? tg3_start_xmit+0x82f/0xa37
>> [388632.749484] =C2=A0[<c12b778b>] ? dev_hard_start_xmit+0x27e/0x4f8
>> [388632.749495] =C2=A0[<c130e851>] ? ip_fragment+0x7dd/0x7dd
>> [388632.749500] =C2=A0[<c12e8b88>] ? nf_iterate+0x66/0x87
=2E..
>
> You hit a known tg3 hardware bug, and the workaround needs to copy sk=
b
> to a new one.
>
> Since TCP layer can build big skbs if TSO is on, and you can hit an
> allocation error because your memory gets fragmented after a while, a
> way to avoid this is to switch off TSO :
>
> ethtool -K eth0 tso off
> ip route flush cache
>
>

Well, Eric, thanks for the explanation! I will disable TSO and will
see how is that working out for me - if I recall correctly, I had no
problems when TSO was off.

Sorry to bother you, if the above explanation was somewhere readily
available, but I didn't manage to find it.

Thanks,
Plamen
