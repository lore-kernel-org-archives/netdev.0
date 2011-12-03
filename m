From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] r8169: Support for byte queue limits
Date: Sat, 03 Dec 2011 07:48:11 +0100
Message-ID: <1322894891.2762.76.camel@edumazet-laptop>
References: <igorm@etf.rs> <1322831399-23505-1-git-send-email-igorm@etf.rs>
	 <1322836191.2762.3.camel@edumazet-laptop>
	 <CAFdo_mVwRgB3OEBA7=nMcemr1x1WLkXC05UAnDW_n5gyYy9W=A@mail.gmail.com>
	 <1322838687.2762.18.camel@edumazet-laptop>
	 <6b84ddc047f72f8a66cc587a1813fbe9.squirrel@kondor.etf.bg.ac.rs>
	 <1322844451.2762.36.camel@edumazet-laptop>
	 <CAFdo_mWtxexXXCpFZsQKAJ96ZXEnDRiBsb4zFO8oR0hc6gXPMQ@mail.gmail.com>
	 <1322845932.2762.38.camel@edumazet-laptop>
	 <CAFdo_mUZembr4MEGUt9efNtfnuCs4ddHUCDjLE64WnWwytTpzw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	Realtek linux nic maintainers <nic_swsd@realtek.com>,
	Francois Romieu <romieu@fr.zoreil.com>,
	Tom Herbert <therbert@google.com>
To: igorm@etf.rs
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:45156 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751228Ab1LCGsQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 3 Dec 2011 01:48:16 -0500
Received: by wgbdr13 with SMTP id dr13so2709729wgb.1
        for <netdev@vger.kernel.org>; Fri, 02 Dec 2011 22:48:15 -0800 (PST)
In-Reply-To: <CAFdo_mUZembr4MEGUt9efNtfnuCs4ddHUCDjLE64WnWwytTpzw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 02 d=C3=A9cembre 2011 =C3=A0 22:54 +0100, Igor Maravi=C4=87=
 a =C3=A9crit :
> >
> > Reread what I said : "BQL must be lightweight"
> >
> > Not : "No lock should be used"
> >
> > OK ?
> >
>=20
> I'm out of ideas.
>=20
> Do you think, if I remove netdev_reset_queue(tp->dev); from
> rtl8169_init_ring_indexes,
> and spin_locks, of course, that would be a good solution.
>=20
> As far as I could see in marvell/sky2.c,  sfc/tx.c and intel/e1000e/n=
etdev.c
> netdev_completed is called with out any lock.
> Please correct me if I'm wrong.

These drivers have a clean and separate start_xmit() and xmit_completio=
n
path, each one being correctly serialized. No extra lock needed.

In the case of r8169, we are still trying to get the driver in a clean
state (without races).

Then, we'll add BQL, and it will be as easy as other drivers.
