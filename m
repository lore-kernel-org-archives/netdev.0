From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] r8169: Support for byte queue limits
Date: Fri, 02 Dec 2011 17:47:31 +0100
Message-ID: <1322844451.2762.36.camel@edumazet-laptop>
References: <igorm@etf.rs> <1322831399-23505-1-git-send-email-igorm@etf.rs>
	 <1322836191.2762.3.camel@edumazet-laptop>
	 <CAFdo_mVwRgB3OEBA7=nMcemr1x1WLkXC05UAnDW_n5gyYy9W=A@mail.gmail.com>
	 <1322838687.2762.18.camel@edumazet-laptop>
	 <6b84ddc047f72f8a66cc587a1813fbe9.squirrel@kondor.etf.bg.ac.rs>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	Realtek linux nic maintainers <nic_swsd@realtek.com>,
	Francois Romieu <romieu@fr.zoreil.com>,
	Tom Herbert <therbert@google.com>
To: igorm@etf.rs
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lpp01m010-f46.google.com ([209.85.215.46]:58061 "EHLO
	mail-lpp01m010-f46.google.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755757Ab1LBQrg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Dec 2011 11:47:36 -0500
Received: by lagp5 with SMTP id p5so263358lag.19
        for <netdev@vger.kernel.org>; Fri, 02 Dec 2011 08:47:35 -0800 (PST)
In-Reply-To: <6b84ddc047f72f8a66cc587a1813fbe9.squirrel@kondor.etf.bg.ac.rs>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 02 d=C3=A9cembre 2011 =C3=A0 17:31 +0100, "Igor Maravi=C4=87=
" a =C3=A9crit :
> >
> > Quite frankly, any queued skb is eventually freed, so
> > netdev_reset_queue() could be avoided.
> >
>=20
> If I didn't add netdev_reset_queue(), how dql would reset its paramet=
ers to 0?
>=20

They are initted at device setup.

As I said, if every transmitted skb is correctly freed (and BQL
accounted), there is no need to netdev_reset_queue()

> I added spin_locks around netdev_completed_queue and netdev_sent_queu=
e
>=20

Oh well, no, dont do that. BQL must be lightweight.
