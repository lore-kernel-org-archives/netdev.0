From: Vasiliy Kulikov <segoon@openwall.com>
Subject: Re: [PATCH v2] core: dev: don't call BUG() on bad input
Date: Mon, 14 Feb 2011 18:23:10 +0300
Message-ID: <20110214152310.GA24429@albatros>
References: <1297694579-23611-1-git-send-email-segoon@openwall.com>
 <AANLkTimidxVJxw-XKTWwCZh8k_vKHDeqxAwVbY6+aJ6x@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Tom Herbert <therbert@google.com>,
	Changli Gao <xiaosuo@gmail.com>,
	Jesse Gross <jesse@nicira.com>, netdev@vger.kernel.org
To: Alexey Dobriyan <adobriyan@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <AANLkTimidxVJxw-XKTWwCZh8k_vKHDeqxAwVbY6+aJ6x@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Alexey,

On Mon, Feb 14, 2011 at 17:16 +0200, Alexey Dobriyan wrote:
> On Mon, Feb 14, 2011 at 4:42 PM, Vasiliy Kulikov <segoon@openwall.com=
> wrote:
> > alloc_netdev() may be called with too long name (more that IFNAMSIZ=
 bytes).
> > Currently this leads to BUG(). =A0Other insane inputs (bad txqs, rx=
qs) and
> > even OOM don't lead to BUG(). =A0Made alloc_netdev() return NULL, l=
ike on
> > other errors.
>=20
> > --- a/net/core/dev.c
> > +++ b/net/core/dev.c
> > @@ -5761,7 +5761,10 @@ struct net_device *alloc_netdev_mqs(int size=
of_priv, const char *name,
> > =A0 =A0 =A0 =A0size_t alloc_size;
> > =A0 =A0 =A0 =A0struct net_device *p;
> >
> > - =A0 =A0 =A0 BUG_ON(strlen(name) >=3D sizeof(dev->name));
> > + =A0 =A0 =A0 if (strnlen(name, sizeof(dev->name)) >=3D sizeof(dev-=
>name)) {
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 pr_err("alloc_netdev: Too long device=
 name\n");
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return NULL;
> > + =A0 =A0 =A0 }
>=20
> Netdevice name isn't some random junk you get from userspace, so BUG =
is fine.

It IS for bluetooth, see net/bluetooth/bnep/core.c: bnep_add_connection=
() and
net/bluetooth/bnep/sock.c: bnep_sock_ioctl().=20

And txqs, txqs?  Then why do not BUG() on bad txqs too?  Why so
insonsistent?  BUG() should be called in some critical situation, net
device creation is probably not such a thing.


Thanks,

--=20
Vasiliy Kulikov
http://www.openwall.com - bringing security into open computing environ=
ments
