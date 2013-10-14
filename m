From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: Re: [PATCH] staging: octeon-ethernet: trivial: Avoid OOPS if phydev
 is not set
Date: Mon, 14 Oct 2013 13:10:51 +0300
Message-ID: <20131014101051.GH6192@mwanda>
References: <1381690794.2848.11.camel@alpha.Speedport_W723_V_Typ_A_1_00_098>
 <20131013212810.GA15167@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: support@caviumnetworks.com, netdev@vger.kernel.org,
 driverdev-devel@linuxdriverproject.org,
 Sebastian =?iso-8859-1?Q?P=F6hn?= <sebastian.poehn@gmail.com>
To: Greg KH <gregkh@linuxfoundation.org>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
Content-Disposition: inline
In-Reply-To: <20131013212810.GA15167@kroah.com>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: driverdev-devel-bounces@linuxdriverproject.org
List-Id: netdev.vger.kernel.org

On Sun, Oct 13, 2013 at 02:28:10PM -0700, Greg KH wrote:
> On Sun, Oct 13, 2013 at 08:59:54PM +0200, Sebastian P=F6hn wrote:
> > A zero pointer deref on priv->phydev->link was causing oops on our syst=
ems.
> > Might be related to improper configuration but we should fail gracefull=
y here ;-)
> > =

> > Signed-off-by: Sebastian Poehn <sebastian.poehn@googlemail.com>
> > =

> > ---
> > =

> > diff --git a/drivers/staging/octeon/ethernet-mdio.c b/drivers/staging/o=
cteon/ethernet-mdio.c
> > index 83b1030..bc8c503 100644
> > --- a/drivers/staging/octeon/ethernet-mdio.c
> > +++ b/drivers/staging/octeon/ethernet-mdio.c
> > @@ -121,6 +121,9 @@ static void cvm_oct_adjust_link(struct net_device *=
dev)
> >         struct octeon_ethernet *priv =3D netdev_priv(dev);
> >         cvmx_helper_link_info_t link_info;
> >  =

> > +       if(!priv->phydev)
> > +               return ;
> =

> Please always run your patches through the scripts/checkpatch.pl tool so
> that maintainers don't have to point out the obvious coding syle errors
> by hand each time :)

Also it's whitespace damaged and doesn't apply.

> =

> Care to try again?
> =

> Also, how was phydev NULL?  What was causing that?

To me it looks like phydev is always NULL.

regards,
dan carpenter
