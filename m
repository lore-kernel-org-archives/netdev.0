From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] r8169: Add 64bit statistics
Date: Sun, 04 Mar 2012 15:32:16 -0800
Message-ID: <1330903936.2474.0.camel@edumazet-laptop>
References: <20120304093727.GA5115@Spy32>
	 <1330875881.2730.15.camel@edumazet-laptop>
	 <20120304232453.GA32314@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Junchang Wang <junchangwang@gmail.com>, davem@davemloft.net,
	netdev@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pw0-f46.google.com ([209.85.160.46]:62502 "EHLO
	mail-pw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754718Ab2CDXcV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 Mar 2012 18:32:21 -0500
Received: by pbcun15 with SMTP id un15so2115645pbc.19
        for <netdev@vger.kernel.org>; Sun, 04 Mar 2012 15:32:21 -0800 (PST)
In-Reply-To: <20120304232453.GA32314@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 05 mars 2012 =C3=A0 00:24 +0100, Francois Romieu a =C3=A9crit =
:
> Eric Dumazet <eric.dumazet@gmail.com> :
> [...]
> > small point : Using this means you have a 32bit hole here (on 32bit
> > build). Its minor, you dont need to change.
>=20
> Ok.
>=20
> [...]
> > 	You could try to put these somewhere else, to try to keep this por=
tion
> > as read only memory, to be more SMP friendly.
> > (Some loaded server could have one CPU serving RX stuff, and other =
cpus
> > doing TX stuff)=20
>=20
> Point taken. It could make sense to rework the rtl8169_private struct=
 a bit
> more.
>=20
> [...]
> > > @@ -6070,20 +6084,49 @@ static void rtl_set_rx_mode(struct net_de=
vice *dev)
> > >  }
> > > =20
> > >  /**
> > > - *  rtl8169_get_stats - Get rtl8169 read/write statistics
> > > + *  rtl8169_get_stats64 - Get rtl8169 read/write statistics
> > >   *  @dev: The Ethernet Device to get statistics for
> >=20
> > missing @stats
>=20
> This documentation is almost useless anyway. I removed it.
>=20
> [...]
> > You dont need _bytes and _packets temp variables, as @stats points =
to a
> > private memory, we can use it as working storage, just do :
> >=20
> >        do {
> >                start =3D u64_stats_fetch_begin_bh(&tp->rx_stats.syn=
cp);
> >                stats->rx_packets =3D tp->rx_stats.packets;
> >                stats->rx_bytes =3D tp->rx_stats.bytes;
> >        } while (u64_stats_fetch_retry_bh(&tp->rx_stats.syncp, start=
));
>=20
> It should give something like the patch below.
>=20
> If I understand correctly we do not care much about the error counter=
s,
> right ?
>=20
> From: Junchang Wang <junchangwang@gmail.com>
> Date: Sun, 4 Mar 2012 23:30:32 +0100
> Subject: [PATCH 1/2] r8169: add 64bit statistics.
>=20
> Switch to use ndo_get_stats64 to get 64bit statistics.
> Two sync entries are used (one for Rx and one for Tx).
>=20
> Signed-off-by: Junchang Wang <junchangwang@gmail.com>
> Reviewed-by: Eric Dumazet <eric.dumazet@gmail.com>
> Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
> ---
>  drivers/net/ethernet/realtek/r8169.c |   59 ++++++++++++++++++++++++=
++--------
>  1 files changed, 45 insertions(+), 14 deletions(-)
>=20

Seems Good To Me, thanks !
