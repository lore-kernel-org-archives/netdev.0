From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: r8169 :  always copying the rx buffer to new skb
Date: Wed, 27 Apr 2011 05:57:37 +0200
Message-ID: <1303876657.2699.22.camel@edumazet-laptop>
References: <4DAC7001.9060800@hotmail.com>
	 <1303147676.2857.20.camel@bwh-desktop> <4DACAC7E.4070400@hotmail.com>
	 <20110420191316.GA18805@electric-eye.fr.zoreil.com>
	 <4DAFA9F9.5080909@hotmail.com>  <4DB77D03.9070507@hotmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Francois Romieu <romieu@fr.zoreil.com>, netdev@vger.kernel.org,
	Ben Hutchings <bhutchings@solarflare.com>, nic_swsd@realtek.com
To: John Lumby <johnlumby@hotmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:36928 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751826Ab1D0D5n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Apr 2011 23:57:43 -0400
Received: by wwa36 with SMTP id 36so1432864wwa.1
        for <netdev@vger.kernel.org>; Tue, 26 Apr 2011 20:57:42 -0700 (PDT)
In-Reply-To: <4DB77D03.9070507@hotmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 26 avril 2011 =C3=A0 22:18 -0400, John Lumby a =C3=A9crit :
> Anyone have any further thoughts on the proposal to avoid memcpy'ing?=
 =20
> (see earlier post)
>=20
> I also have a question concerning NAPI.     I've found that much of t=
he=20
> CPU saved from not memcpy'ing is burned in extra rx_interrupt'ing,  a=
nd=20
> much of that seems to be wasted (no new packets).    So the actual=20
> benefit is rather less than I think should be possible.
>=20
> I've tried some tinkering with the napi weight but can't find any=20
> setting which really improves the ratio of rx packets to hard interru=
pts=20
> significantly.    The problem seems to be that each successive=20
> rtl8169_poll() is driven too soon after the last one   (in this=20
> particular workload).     The napi weight doesn't directly influence =
that.
>=20
> So  -  question :
> is there any way,   when returning from rtl8169_poll,  to tell napi=20
> something like :
>     "   finish this interrupt context and let something else run on t=
his=20
> CPU  (always CPU0 on my machine) BUT reschedule another napi poll on=20
> this same device at some time after that "
> the point being that rtl8169_poll will,  for this case,  NOT re-enabl=
e=20
> the NIC's napi interrupts,  in the hope that maybe some user work can=
 be=20
> dispatched,    so something else will have to schedule the next napi=20
> poll for it.    Conceptually,    if rtl8169_poll finds no rx work don=
e=20
> on this call,   it wants to cause a yield() and then try again.    =20
> Except it can't from within the interrupt.
>=20
> I appreciate this could lead to delays in handling new work so might =
be=20
> dangerous,    but it seems to me to be in line with NAPI objectives s=
o I=20
> wanted to try it .   But don't know how.     Any hints or thoughts=20
> appreciated.

Answer is no. There is no such facility in NAPI infrastructure.

You want to introduce a timer based polling. Some old pre-NAPI drivers
were doing that. Its OK when you have one device to handle, it can be a
nightmare when you mix several devices.



