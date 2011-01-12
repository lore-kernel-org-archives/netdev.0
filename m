From: Jarek Poplawski <jarkao2-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: rndis gadget: Inconsistent locking
Date: Wed, 12 Jan 2011 13:41:36 +0000
Message-ID: <20110112134136.GB9920@ff.dom.local>
References: <20110112122811.GA9513@ff.dom.local> <1294837632.3981.18.camel@edumazet-laptop> <20110112132314.GA9920@ff.dom.local> <1294839140.3981.23.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Brownell <david-b-yBeKhBN/0LDR7s880joybQ@public.gmane.org>,
	=?iso-8859-2?Q?Micha=B3?= Nazarewicz <m.nazarewicz-Sze3O3UU22JBDgjK7y7TUQ@public.gmane.org>,
	Neil Jones <neiljay-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1294839140.3981.23.camel@edumazet-laptop>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, Jan 12, 2011 at 02:32:20PM +0100, Eric Dumazet wrote:
> Le mercredi 12 janvier 2011 ?? 13:23 +0000, Jarek Poplawski a =E9crit=
 :
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

Well, I'm OK with anything, but this thread gets older and older ;-)

Jarek P.
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
