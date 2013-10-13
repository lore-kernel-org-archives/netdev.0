From: Greg KH <gregkh@linuxfoundation.org>
Subject: Re: [PATCH] staging: octeon-ethernet: trivial: Avoid OOPS if phydev
 is not set
Date: Sun, 13 Oct 2013 14:28:10 -0700
Message-ID: <20131013212810.GA15167@kroah.com>
References: <1381690794.2848.11.camel@alpha.Speedport_W723_V_Typ_A_1_00_098>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: support@caviumnetworks.com, netdev@vger.kernel.org,
 driverdev-devel@linuxdriverproject.org
To: Sebastian =?iso-8859-1?Q?P=F6hn?= <sebastian.poehn@gmail.com>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
Content-Disposition: inline
In-Reply-To: <1381690794.2848.11.camel@alpha.Speedport_W723_V_Typ_A_1_00_098>
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

On Sun, Oct 13, 2013 at 08:59:54PM +0200, Sebastian P=F6hn wrote:
> A zero pointer deref on priv->phydev->link was causing oops on our system=
s.
> Might be related to improper configuration but we should fail gracefully =
here ;-)
> =

> Signed-off-by: Sebastian Poehn <sebastian.poehn@googlemail.com>
> =

> ---
> =

> diff --git a/drivers/staging/octeon/ethernet-mdio.c b/drivers/staging/oct=
eon/ethernet-mdio.c
> index 83b1030..bc8c503 100644
> --- a/drivers/staging/octeon/ethernet-mdio.c
> +++ b/drivers/staging/octeon/ethernet-mdio.c
> @@ -121,6 +121,9 @@ static void cvm_oct_adjust_link(struct net_device *de=
v)
>         struct octeon_ethernet *priv =3D netdev_priv(dev);
>         cvmx_helper_link_info_t link_info;
>  =

> +       if(!priv->phydev)
> +               return ;

Please always run your patches through the scripts/checkpatch.pl tool so
that maintainers don't have to point out the obvious coding syle errors
by hand each time :)

Care to try again?

Also, how was phydev NULL?  What was causing that?

thanks,

greg k-h
