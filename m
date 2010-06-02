From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH net-next-2.6] net: replace hooks in __netif_receive_skb
 V5
Date: Wed, 2 Jun 2010 13:43:45 -0700
Message-ID: <20100602204345.GE2385@linux.vnet.ibm.com>
References: <20100527180813.GA3714@psychotron.redhat.com>
 <20100527130822.02cb1661@nehalam>
 <20100528055154.GB2823@psychotron.redhat.com>
 <20100528061241.GC2823@psychotron.redhat.com>
 <1275030163.2650.3.camel@edumazet-laptop>
 <20100528073345.GD2823@psychotron.redhat.com>
 <20100601082805.1c84b16d@nehalam>
 <20100602075207.GD2603@psychotron.redhat.com>
 <20100602080730.53abea6d@nehalam>
 <1275491722.2725.184.camel@edumazet-laptop>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	Jiri Pirko <jpirko@redhat.com>, netdev@vger.kernel.org,
	davem@davemloft.net, kaber@trash.net
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e2.ny.us.ibm.com ([32.97.182.142]:37268 "EHLO e2.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758027Ab0FBUny (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Jun 2010 16:43:54 -0400
Received: from d01relay01.pok.ibm.com (d01relay01.pok.ibm.com [9.56.227.233])
	by e2.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id o52KVUgJ017975
	for <netdev@vger.kernel.org>; Wed, 2 Jun 2010 16:31:30 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay01.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o52KhrfS102630
	for <netdev@vger.kernel.org>; Wed, 2 Jun 2010 16:43:53 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o52Khq6J004524
	for <netdev@vger.kernel.org>; Wed, 2 Jun 2010 16:43:53 -0400
Content-Disposition: inline
In-Reply-To: <1275491722.2725.184.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 02, 2010 at 05:15:22PM +0200, Eric Dumazet wrote:
> Le mercredi 02 juin 2010 =E0 08:07 -0700, Stephen Hemminger a =E9crit=
 :
> > On Wed, 2 Jun 2010 09:52:08 +0200
> > Jiri Pirko <jpirko@redhat.com> wrote:
> >=20
> > > +
> > > +	err =3D netdev_rx_handler_register(dev, macvlan_handle_frame);
> > > +	if (err) {
> > > +		rcu_assign_pointer(dev->macvlan_port, NULL);
> > > +		kfree(port);
> > > +	}
> > > +
> > > +	return err;
> > >  }
> >=20
> > Rcu assign is not necessary here for because the hook didn't
> > get registered so there is no way for other CPU to see it.
> >=20
>=20
> Thats a valid point, but we should use it, and not care of this litle
> detail. Compiler generates same code anyway, since NULL value is test=
ed
> by rcu_assign_pointer().
>=20
> If we dont use rcu_assign_pointer() ourself, Paul or Arnd will put it
> one day or another :)
>=20
> http://lkml.org/lkml/2010/6/1/290

Some year soon, I hope.  ;-)

							Thanx, Paul
