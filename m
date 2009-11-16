From: "=?iso-8859-1?q?R=E9mi?= Denis-Courmont" <remi@remlab.net>
Subject: Re: [PATCH net-next 1/2] Phonet: put protocols array under RCU
Date: Mon, 16 Nov 2009 19:34:00 +0200
Message-ID: <200911161934.00365.remi@remlab.net>
References: <1258124479-1167-1-git-send-email-remi@remlab.net> <20091116172617.GC6746@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	"=?iso-8859-1?q?R=E9mi?= Denis-Courmont"
	<remi.denis-courmont@nokia.com>
To: paulmck@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from yop.chewa.net ([91.121.105.214]:34066 "EHLO yop.chewa.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751542AbZKPRd4 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Nov 2009 12:33:56 -0500
In-Reply-To: <20091116172617.GC6746@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 16 novembre 2009 19:26:17 Paul E. McKenney, vous avez =E9crit =
:
> On Fri, Nov 13, 2009 at 05:01:18PM +0200, R=E9mi Denis-Courmont wrote=
:
> > From: R=E9mi Denis-Courmont <remi.denis-courmont@nokia.com>
> >
> > Signed-off-by: R=E9mi Denis-Courmont <remi.denis-courmont@nokia.com=
>
> > ---
> >  net/phonet/af_phonet.c |   20 +++++++++++---------
> >  1 files changed, 11 insertions(+), 9 deletions(-)
> >
> > diff --git a/net/phonet/af_phonet.c b/net/phonet/af_phonet.c
> > index 8d3a55b..ed65da2 100644
> > --- a/net/phonet/af_phonet.c
> > +++ b/net/phonet/af_phonet.c
> > @@ -35,7 +35,6 @@
> >
> >  /* Transport protocol registration */
> >  static struct phonet_protocol *proto_tab[PHONET_NPROTO] __read_mos=
tly;
> > -static DEFINE_SPINLOCK(proto_tab_lock);
> >
> >  static struct phonet_protocol *phonet_proto_get(int protocol)
> >  {
> > @@ -44,11 +43,11 @@ static struct phonet_protocol *phonet_proto_get=
(int
> > protocol) if (protocol >=3D PHONET_NPROTO)
> >  		return NULL;
> >
> > -	spin_lock(&proto_tab_lock);
> > +	rcu_read_lock();
> >  	pp =3D proto_tab[protocol];
>=20
> Don't we need an rcu_dereference() in here somewhere?
>=20
> Perhaps something like the following?

Err yes, we do.

--=20
R=E9mi Denis-Courmont
http://www.remlab.net/
