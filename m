From: Imre Deak <imre.deak@intel.com>
Subject: Re: [PATCH 06/11] net/bonding: take msecs_to_jiffies_min into use
Date: Sat, 11 May 2013 00:19:36 +0300
Message-ID: <1368220776.18714.30.camel@ideak-mobl>
References: <1368188011-23661-1-git-send-email-imre.deak@intel.com>
	 <1368188011-23661-6-git-send-email-imre.deak@intel.com>
	 <20130510135810.GA30139@unicorn.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	Daniel Vetter <daniel.vetter@ffwll.ch>,
	Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>, netdev@vger.kernel.org
To: Michal Kubecek <mkubecek@suse.cz>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130510135810.GA30139@unicorn.suse.cz>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2013-05-10 at 15:58 +0200, Michal Kubecek wrote:
> On Fri, May 10, 2013 at 03:13:24PM +0300, Imre Deak wrote:
> > --- a/drivers/net/bonding/bond_main.c
> > +++ b/drivers/net/bonding/bond_main.c
> > @@ -1751,7 +1751,7 @@ int bond_enslave(struct net_device *bond_dev,=
 struct net_device *slave_dev)
> >  	read_lock(&bond->lock);
> > =20
> >  	new_slave->last_arp_rx =3D jiffies -
> > -		(msecs_to_jiffies(bond->params.arp_interval) + 1);
> > +		(msecs_to_jiffies_min(bond->params.arp_interval));
> > =20
> >  	if (bond->params.miimon && !bond->params.use_carrier) {
> >  		link_reporting =3D bond_check_dev_link(bond, slave_dev, 1);
>=20
> This "+ 1" was actually meant as "plus one". We need to ensure that
>=20
>   slave->last_arp_rx + msecs_to_jiffies(bond->params.arp_interval)
>=20
> is strictly less than current value of jiffies.

Ok, I see, the adjustment here is for a different reason and
msecs_to_jiffies_min wouldn't express this properly. So we should drop
this patch. Perhaps it'd be nice to add something like the above
explanation as a code comment, to make it clear that the adjustment is
not for guaranteeing a minimum duration as it is in many other places.

--Imre

> So with proposed
> definition of msecs_to_jiffies_min() it works correctly but if the
> implementation ever changes in such way that
>=20
>   msecs_to_jiffies_min(x) >=3D msecs_to_jiffies(x)
>=20
> for some value of x, the code would be incorrect.
>=20
>                                                        Michal Kube=C4=
=8Dek
>=20
