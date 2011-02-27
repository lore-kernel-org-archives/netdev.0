From: "Gustavo F. Padovan" <padovan-Y3ZbgMPKUGA34EUeqzHoZw@public.gmane.org>
Subject: Re: [PATCH] Bluetooth: Fix BT_L2CAP and BT_SCO in Kconfig
Date: Sun, 27 Feb 2011 16:19:01 -0300
Message-ID: <20110227191901.GC2166@joana>
References: <20110226013639.GA2166@joana>
 <1298684485-3081-1-git-send-email-padovan@profusion.mobi>
 <AANLkTimuyx4ixPq5BexRHozebVpjry2k-2xskqVf79g1@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org,
	linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Vitaly Wool <vitalywool-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <AANLkTimuyx4ixPq5BexRHozebVpjry2k-2xskqVf79g1-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Vitaly,

* Vitaly Wool <vitalywool-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> [2011-02-26 18:52:44 +0100]:

> Hi Gustavo,
>=20
> On Sat, Feb 26, 2011 at 2:41 AM, Gustavo F. Padovan
> <padovan-Y3ZbgMPKUGA34EUeqzHoZw@public.gmane.org> wrote:
> > If we want something "bool" built-in in something "tristate" it can=
't
> > "depend on" the tristate config option.
> >
> > Report by DaveM:
> >
> > =A0 I give it 'y' just to make it happen, for both, and afterways n=
o
> > =A0 matter how many times I rerun "make oldconfig" I keep seeing th=
ings
> > =A0 like this in my build:
> >
> > scripts/kconfig/conf --silentoldconfig Kconfig
> > include/config/auto.conf:986:warning: symbol value 'm' invalid for =
BT_SCO
> > include/config/auto.conf:3156:warning: symbol value 'm' invalid for=
 BT_L2CAP
> >
> > Reported-by: David S. Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
> > Signed-off-by: Gustavo F. Padovan <padovan-Y3ZbgMPKUGA34EUeqzHoZw@public.gmane.org>
> > ---
> > =A0net/bluetooth/Kconfig | =A0 =A06 ++++--
> > =A01 files changed, 4 insertions(+), 2 deletions(-)
> >
> > diff --git a/net/bluetooth/Kconfig b/net/bluetooth/Kconfig
> > index c6f9c2f..6ae5ec5 100644
> > --- a/net/bluetooth/Kconfig
> > +++ b/net/bluetooth/Kconfig
> > @@ -31,9 +31,10 @@ menuconfig BT
> > =A0 =A0 =A0 =A0 =A0to Bluetooth kernel modules are provided in the =
BlueZ packages. =A0For
> > =A0 =A0 =A0 =A0 =A0more information, see <http://www.bluez.org/>.
> >
> > +if BT !=3D n
> > +
> > =A0config BT_L2CAP
> > =A0 =A0 =A0 =A0bool "L2CAP protocol support"
> > - =A0 =A0 =A0 depends on BT
> > =A0 =A0 =A0 =A0select CRC16
> > =A0 =A0 =A0 =A0help
> > =A0 =A0 =A0 =A0 =A0L2CAP (Logical Link Control and Adaptation Proto=
col) provides
> > @@ -42,11 +43,12 @@ config BT_L2CAP
> >
> > =A0config BT_SCO
> > =A0 =A0 =A0 =A0bool "SCO links support"
> > - =A0 =A0 =A0 depends on BT
> > =A0 =A0 =A0 =A0help
> > =A0 =A0 =A0 =A0 =A0SCO link provides voice transport over Bluetooth=
=2E =A0SCO support is
> > =A0 =A0 =A0 =A0 =A0required for voice applications like Headset and=
 Audio.
> >
> > +endif
> > +
>=20
> Ugh, isn't it far cleaner to change initial dependencies to "depends
> on BT !=3D n" ?

I just followed the same approach as net/ipv6/Kconfig and
net/mac80211/Kconfig.=20

Dave, how do you prefer this?

--=20
Gustavo F. Padovan
http://profusion.mobi
