From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: RE: [PATCH net-next] r8169: Add 64bit statistics
Date: Thu, 17 Nov 2011 13:58:20 +0100
Message-ID: <1321534700.2751.27.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <AE90C24D6B3A694183C094C60CF0A2F6D8AEC9@saturn3.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Junchang Wang <junchangwang@gmail.com>,
	Stephen Hemminger <stephen.hemminger@vyatta.com>,
	netdev@vger.kernel.org, romieu@fr.zoreil.com,
	nic swsd <nic_swsd@realtek.com>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:59646 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754292Ab1KQM60 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Nov 2011 07:58:26 -0500
Received: by bke11 with SMTP id 11so1940963bke.19
        for <netdev@vger.kernel.org>; Thu, 17 Nov 2011 04:58:25 -0800 (PST)
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6D8AEC9@saturn3.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 17 novembre 2011 =C3=A0 11:13 +0000, David Laight a =C3=A9crit=
 :
> The 64bit stats update sequence used to get valid
> counts on 32bit systems (that can't do locked 64bit
> memory access) seems to be:
>=20
> >     u64_stats_update_begin(&sky2->tx_stats.syncp);
> >     ++sky2->tx_stats.packets;
> >     sky2->tx_stats.bytes +=3D skb->len;
> >     u64_stats_update_end(&sky2->tx_stats.syncp);
>=20
> I'm not sure what the begin/end markers do, but
> they need to hold off the readers during updates
> and the writers during reads - this is probably
> expensive on the update path.
>=20
> A thought that might work is for the writer to
> write the middle bits of the 64 bit walue to
> another location, eg:
>        count =3D sky2->tx_stats.bytes + skb->len;
>        sky2->tx_stats.bytes =3D count;
>        sky2->tx_stats.bytes_check =3D count >> 16;
> The reader then loops until the two value are
> consistent.
>=20
> I think this doesn't even require a memory barrier
> in the ISR since the order of the reads an writes
> doesn't matter at all.
>=20
> 	David
>=20
>=20

Oh well...

Before claiming all this, you really should read=20
include/linux/u64_stats_sync.h

This should answer all your questions.
