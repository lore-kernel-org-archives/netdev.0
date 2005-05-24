From: Jirka Bohac <jbohac@suse.cz>
Subject: Re: [4/6] ipw2100: fix after "ieee80211_device alignment fix"
Date: Tue, 24 May 2005 21:18:33 +0200
Message-ID: <20050524191832.GA10297@dwarf.suse.cz>
References: <20050524150711.01632672@griffin.suse.cz> <20050524151802.59124dde@griffin.suse.cz> <20050524185820.GC2268@elf.ucw.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: quoted-printable
Cc: Jiri Benc <jbenc@suse.cz>, NetDev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Pavel Machek <pavel@suse.cz>
Content-Disposition: inline
In-Reply-To: <20050524185820.GC2268@elf.ucw.cz>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, May 24, 2005 at 08:58:20PM +0200, Pavel Machek wrote:
> On =DAt 24-05-05 15:18:02, Jiri Benc wrote:
> > Fixes ipw2100 after ieee80211_device alignment fix
> > (patch [2/5] ieee80211: ieee80211_device alignment fix and cleanup)
> >=20
> >=20
> > Signed-off-by: Jiri Benc <jbenc@suse.cz>
> > Signed-off-by: Jirka Bohac <jbohac@suse.cz>
> >=20
> > --- linux-2.6.12-rc2-mm3.01/drivers/net/wireless/ipw2100.c	2005-05-19=
 16:23:00.000000000 +0200
> > +++ linux-2.6.12-rc2-mm3.04/drivers/net/wireless/ipw2100.c	2005-05-19=
 17:35:48.000000000 +0200
> > @@ -1717,7 +1717,7 @@
> >  /* Called by register_netdev() */
> >  static int ipw2100_net_init(struct net_device *dev)
> >  {
> > -	struct ipw2100_priv *priv =3D ieee80211_priv(dev);
> > +	struct ipw2100_priv *priv =3D ieee80211_priv(netdev_priv(dev));
> >  	return ipw2100_up(priv, 1);
> >  }
>=20
>=20
> Ugh, that is getting rather ugly. Perhaps inline function doing this
> should be introduced?

Ok, this is a little ugly, but this driver is slowly getting
re-written as work on the ieee80211 layer proceeds.=20

Drivers will not be supposed to use references to struct net_device
internally. Instead, they should be using references to struct
ieee80211_device -- this will be their interface to the stack,
not net_device. So this patch is a quick fix for the driver to
work with the unfinished layer. This "call" will disappear when
the layer is finished.

Both ieee80211_priv() and netdev_priv() are inline.


Regards,


--=20
Jirka Bohac <jbohac@suse.cz>
SUSE Labs, SUSE CR
