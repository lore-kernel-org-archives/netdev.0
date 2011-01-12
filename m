From: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: rndis gadget: Inconsistent locking
Date: Wed, 12 Jan 2011 14:52:59 +0100
Message-ID: <1294840379.3981.31.camel@edumazet-laptop>
References: <20110112122811.GA9513@ff.dom.local>
	 <1294837632.3981.18.camel@edumazet-laptop>
	 <20110112132314.GA9920@ff.dom.local>
	 <1294839140.3981.23.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Brownell <david-b-yBeKhBN/0LDR7s880joybQ@public.gmane.org>,
	=?UTF-8?Q?Micha=C5=82?= Nazarewicz <m.nazarewicz-Sze3O3UU22JBDgjK7y7TUQ@public.gmane.org>,
	Neil Jones <neiljay-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Jarek Poplawski <jarkao2-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1294839140.3981.23.camel@edumazet-laptop>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Le mercredi 12 janvier 2011 =C3=A0 14:32 +0100, Eric Dumazet a =C3=A9cr=
it :
> Le mercredi 12 janvier 2011 =C3=A0 13:23 +0000, Jarek Poplawski a =C3=
=A9crit :
> > On Wed, Jan 12, 2011 at 02:07:12PM +0100, Eric Dumazet wrote:
> > ...
> > >=20
> > > Hmm...=20
> > >=20
> > > So all net devices in gen_ndis_query_resp() should have a
> > > ndo_get_stats() or ndo_get_stats64() method, not allowed to use
> > > spin_lock_bh() / spin_unlock_bh()
> > >=20
> > > If yes, we should add big fat comments to pn_net_stats()/eth_get_=
stats() so that nobody
> > > tries to revert your patch ;)
> >=20
> > I'm not sure I got your point: my patch could be replaced with
> > ndo_get_stats64() implementing irq safe locking or by changing
> > gen_ndis_query_resp() calling context. It's intended as a fast
> > (compatible) fix.
>=20
> I was mentioning that we tried in past months to remove useless
> ndo_get_stats() methods that were only doing :
>=20
> return &net->stats;
>=20
> random commit : b27d50a9ff5cf2775b7a4daf5
>=20
> Another possibility would be to use u64_stats_sync.h for these txq
> counters.
>=20
> (no locking needed to read counters, only a seqcount fetch/retry)
>=20
> As a bonus, no overhead on 64bit arches.
>=20

Or even better, remove these counters since there is no users left but
ixgbe.

(vlans, tunnels, ... now use percpu stats)



--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
