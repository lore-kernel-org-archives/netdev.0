From: Neil Horman <nhorman@redhat.com>
Subject: Re: [Patch net-next-2.6] netpoll: disable netpoll when enslave a
 device
Date: Thu, 19 May 2011 07:03:14 -0400
Message-ID: <20110519110314.GC2723@hmsreliant.think-freely.org>
References: <1305712845-11762-1-git-send-email-amwang@redhat.com>
 <20110518105558.GA3203@hmsreliant.think-freely.org>
 <4DD4A6F9.4010002@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Neil Horman <nhorman@tuxdriver.com>, linux-kernel@vger.kernel.org,
	Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Dobriyan <adobriyan@gmail.com>,
	Ferenc Wagner <wferi@niif.hu>,
	Andrew Morton <akpm@linux-foundation.org>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Josh Triplett <josh@joshtriplett.org>,
	Ian Campbell <ian.campbell@citrix.com>, netdev@vger.kernel.org
To: Cong Wang <amwang@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4DD4A6F9.4010002@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, May 19, 2011 at 01:13:29PM +0800, Cong Wang wrote:
> =E4=BA=8E 2011=E5=B9=B405=E6=9C=8818=E6=97=A5 18:56, Neil Horman =E5=86=
=99=E9=81=93:
> >On Wed, May 18, 2011 at 06:00:35PM +0800, Amerigo Wang wrote:
> ...
> >>-			case NETDEV_GOING_DOWN:
> >>  			case NETDEV_BONDING_DESLAVE:
> >>+			case NETDEV_ENSLAVE:
> >>  				nt->enabled =3D 0;
> >>  				stopped =3D true;
> >>  				break;
> >This wasn't introduced by this patch, but looking at it made me real=
ize that
> >nt->enabled, if it passes through this code path, doesn't properly t=
rack weather
> >or not netpoll_setup has been called on this interface.  If you look=
 at
> >drop_netconsole_target, you'll see we only call netpoll_cleanup_targ=
et if
> >nt->enabled is set.  We should probably change the nt->enabled check=
 there, and
> >in store_enabled to be if (nt->np.dev), like we do in the NETDEV_UNR=
EGISTER case
> >in netconsole_netdev_event.
>=20
> Yeah, also note that we can change ->enabled via configfs too.
> I guess we probably need to fix this in another patch...
>=20
Yeah, or you can roll it into this one, I think this is the only locati=
on that
needs fixing.

>=20
> >>+#define NETDEV_ENSLAVE		0x0014
> >>
> >Nit:
> >Shouldn't this be NETDEV_BONDING_ENSLAVE, to keep it in line with
> >NETDEV_BONDING_DESLAVE above?
>=20
> Actually that is my first thought, but I plan to use this in bridge
> case too, because using netconsole on a device underlying a bridge
> makes little sense too. Thus, I prefer NETDEV_ENSLAVE to
> NETDEV_BONDING_ENSLAVE.
>=20
That seems reasonable, but if its going to be more generic, could you c=
hange
NETDEV_BONDING_DESLAVE to NETDEV_DESLAVE?

> >
> >>  #define SYS_DOWN	0x0001	/* Notify of system down */
> >>  #define SYS_RESTART	SYS_DOWN
> >>
> >
> >
> >Other than those two points, this looks good to me
>=20
> Thanks for review.
Thank you!
