From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v3] drivers/net/tulip/de4x5.c: fix union member name in
 DE4X5_GET_REG ioctl
Date: Fri, 17 Sep 2010 07:31:55 +0200
Message-ID: <1284701515.4784.35.camel@edumazet-laptop>
References: <1284586998.6275.94.camel@dan>
	 <20100916.215313.180410528.davem@davemloft.net>
	 <1284699944.2565.4.camel@dan>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, grundler@parisc-linux.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	kyle@mcmartin.ca, jeffm@suse.com, security@kernel.org
To: Dan Rosenberg <drosenberg@vsecurity.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1284699944.2565.4.camel@dan>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le vendredi 17 septembre 2010 =C3=A0 01:05 -0400, Dan Rosenberg a =C3=A9=
crit :
> Now with descriptive title, as requested.
>=20
> This was previously reported as a security issue due to leakage of
> uninitialized stack memory.  Jeff Mahoney pointed out that this is
> incorrect since the copied data is from a union (rather than a struct=
).
> Therefore, this patch is only under consideration for the sake of
> correctness, and is not security relevant.=20
>=20
> Signed-off-by: Dan Rosenberg <dan.j.rosenberg@gmail.com>
> Acked-by: Grant Grundler <grundler@parisc-linux.org>
>=20
> --- linux-2.6.35.4.orig/drivers/net/tulip/de4x5.c       2010-08-26 19=
:47:12.000000000 -0400
> +++ linux-2.6.35.4/drivers/net/tulip/de4x5.c    2010-09-14 21:26:52.4=
99474207 -0400
> @@ -5474,7 +5474,7 @@ de4x5_ioctl(struct net_device *dev, stru
>         tmp.lval[6] =3D inl(DE4X5_STRR); j+=3D4;
>         tmp.lval[7] =3D inl(DE4X5_SIGR); j+=3D4;
>         ioc->len =3D j;
> -       if (copy_to_user(ioc->data, tmp.addr, ioc->len)) return -EFAU=
LT;
> +       if (copy_to_user(ioc->data, tmp.lval, ioc->len)) return -EFAU=
LT;
>         break;
> =20
>  #define DE4X5_DUMP              0x0f /* Dump the DE4X5 Status */
>=20


While you are at it

	if (copy_to_user(ioc->data, tmp.lval, ioc->len))
		return -EFAULT;

Thanks
