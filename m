From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: RE: [PATCH 06/19] netfilter: nf_conntrack: use atomic64 for
 accounting counters
Date: Tue, 03 Jan 2012 14:37:57 +0100
Message-ID: <1325597877.2320.47.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <AE90C24D6B3A694183C094C60CF0A2F6D8AF28@saturn3.aculab.com>
	 <1325597490.2320.45.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: pablo@netfilter.org, netfilter-devel@vger.kernel.org,
	davem@davemloft.net, netdev@vger.kernel.org
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1325597490.2320.45.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le mardi 03 janvier 2012 =C3=A0 14:31 +0100, Eric Dumazet a =C3=A9crit =
:
> Le mardi 03 janvier 2012 =C3=A0 12:01 +0000, David Laight a =C3=A9cri=
t :
> > >  		if (acct) {
> > > -			spin_lock_bh(&ct->lock);
> > > -			acct[CTINFO2DIR(ctinfo)].packets++;
> > > -			acct[CTINFO2DIR(ctinfo)].bytes +=3D skb->len;
> > > -			spin_unlock_bh(&ct->lock);
> > > +			atomic64_inc(&acct[CTINFO2DIR(ctinfo)].packets);
> > > +			atomic64_add(skb->len,
> > &acct[CTINFO2DIR(ctinfo)].bytes);
> > >  		}
> >=20
> > On a 32bit arch the two atomic64 operations require a locked
> > bus cycle each. The spin_unlock_bh() may not need one - so
> > the code may now be slower (modulo lock contention etc).
> >=20
> > Probably worth caching &acct[CTINFO2DIR(ctinfo)] in a local,
> > the compiler probably can't do it itself.
>=20
> You're mistaken.
>=20
> Compile a UP kernel and check yourself before doing such claims.
>=20
>=20

Oops sorry, I misread your mail, I thought you were speaking of UP
kernel.



--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
