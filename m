From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next-2.6] net: replace hooks in __netif_receive_skb
 V5
Date: Wed, 02 Jun 2010 17:15:22 +0200
Message-ID: <1275491722.2725.184.camel@edumazet-laptop>
References: <20100527180813.GA3714@psychotron.redhat.com>
	 <20100527130822.02cb1661@nehalam>
	 <20100528055154.GB2823@psychotron.redhat.com>
	 <20100528061241.GC2823@psychotron.redhat.com>
	 <1275030163.2650.3.camel@edumazet-laptop>
	 <20100528073345.GD2823@psychotron.redhat.com>
	 <20100601082805.1c84b16d@nehalam>
	 <20100602075207.GD2603@psychotron.redhat.com>
	 <20100602080730.53abea6d@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jiri Pirko <jpirko@redhat.com>, netdev@vger.kernel.org,
	davem@davemloft.net, kaber@trash.net,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f46.google.com ([74.125.82.46]:36457 "EHLO
	mail-ww0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932565Ab0FBPPd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Jun 2010 11:15:33 -0400
Received: by wwb28 with SMTP id 28so2971270wwb.19
        for <netdev@vger.kernel.org>; Wed, 02 Jun 2010 08:15:28 -0700 (PDT)
In-Reply-To: <20100602080730.53abea6d@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 02 juin 2010 =C3=A0 08:07 -0700, Stephen Hemminger a =C3=A9=
crit :
> On Wed, 2 Jun 2010 09:52:08 +0200
> Jiri Pirko <jpirko@redhat.com> wrote:
>=20
> > +
> > +	err =3D netdev_rx_handler_register(dev, macvlan_handle_frame);
> > +	if (err) {
> > +		rcu_assign_pointer(dev->macvlan_port, NULL);
> > +		kfree(port);
> > +	}
> > +
> > +	return err;
> >  }
>=20
> Rcu assign is not necessary here for because the hook didn't
> get registered so there is no way for other CPU to see it.
>=20

Thats a valid point, but we should use it, and not care of this litle
detail. Compiler generates same code anyway, since NULL value is tested
by rcu_assign_pointer().

If we dont use rcu_assign_pointer() ourself, Paul or Arnd will put it
one day or another :)

http://lkml.org/lkml/2010/6/1/290



