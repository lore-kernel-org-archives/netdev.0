From: Andrew de Quincey <adq@lidskialf.net>
Subject: Re: [Fwd: extra spinlocking in forcedeth 0.25]
Date: Wed, 14 Apr 2004 22:37:20 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200404142237.20688.adq@lidskialf.net>
References: <407D6ABE.7010503@gmx.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: Jeff Garzik <jgarzik@pobox.com>, Manfred Spraul <manfred@colorfullife.com>,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Carl-Daniel Hailfinger <c-d.hailfinger.kernel.2004@gmx.net>
In-Reply-To: <407D6ABE.7010503@gmx.net>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wednesday 14 April 2004 17:45, you wrote:
> Andrew,
>
> could you have a look at the attached mail regarding spinlocking in you=
r
> WOL patch for forcedeth?

> In 0.23 -> 0.25 forcedeth diff I noticed this:
>=20
> + =A0 =A0 =A0 case ETHTOOL_GWOL:
> + =A0 =A0 =A0 {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct ethtool_wolinfo wolinfo;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 memset(&wolinfo, 0, sizeof(wolinfo));
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 wolinfo.supported =3D WAKE_MAGIC;
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 spin_lock_irq(&np->lock);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (np->wolenabled)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 wolinfo.wolopts =3D WAKE_=
MAGIC;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 spin_unlock_irq(&np->lock);
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (copy_to_user(useraddr, &wolinfo, size=
of(wolinfo)))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -EFAULT;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return 0;
> + =A0 =A0 =A0 }
>=20
> IMHO this pair of lock()/unlock() is not needed
> and can be safely removed.

Yeah, he's right. Absolutely no need for it there.
