From: Jarek Poplawski <jarkao2-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH] net: remove dev_txq_stats_fold()
Date: Wed, 12 Jan 2011 22:05:18 +0100
Message-ID: <20110112210518.GA2152@del.dom.local>
References: <20110112122811.GA9513@ff.dom.local>
 <1294837632.3981.18.camel@edumazet-laptop>
 <20110112132314.GA9920@ff.dom.local>
 <1294839140.3981.23.camel@edumazet-laptop>
 <1294840379.3981.31.camel@edumazet-laptop>
 <1294844520.3981.84.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	David Brownell <david-b-yBeKhBN/0LDR7s880joybQ@public.gmane.org>,
	=?iso-8859-2?Q?Micha=B3?= Nazarewicz <m.nazarewicz-Sze3O3UU22JBDgjK7y7TUQ@public.gmane.org>,
	Neil Jones <neiljay-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Alexander Duyck <alexander.h.duyck-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Jeff Kirsher <jeffrey.t.kirsher-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
To: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1294844520.3981.84.camel@edumazet-laptop>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, Jan 12, 2011 at 04:02:00PM +0100, Eric Dumazet wrote:
> Le mercredi 12 janvier 2011 ?? 14:52 +0100, Eric Dumazet a =E9crit :
>=20
> > Or even better, remove these counters since there is no users left =
but
> > ixgbe.
> >=20
> > (vlans, tunnels, ... now use percpu stats)
> >=20
> >=20
>=20
> Thanks Jarek for the reminder :)
>=20
> [PATCH] net: remove dev_txq_stats_fold()
>=20
> After recent changes, (percpu stats on vlan/tunnels...), we dont need
> anymore per struct netdev_queue tx_bytes/tx_packets/tx_dropped counte=
rs.
>=20
> Only remaining users are ixgbe, sch_teql & macvlan :

And gianfar (not counting staging/bcm) but I'm not sure if that's all.

>=20
> 1) ixgbe can be converted to use existing tx_ring counters.
>=20
> 2) macvlan incremented txq->tx_dropped, it can use the
> dev->stats.tx_dropped counter.
>=20
> 3) sch_teql : almost revert ab35cd4b8f42 (Use net_device internal sta=
ts)
>     Now we have ndo_get_stats64(), use it.

Btw, why doesn't sch_teql need locking (for 32-bits)?

Jarek P.
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
