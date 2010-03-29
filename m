From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: linux-next: build failure after merge of the final tree (net
 tree related)
Date: Mon, 29 Mar 2010 08:52:41 +0200
Message-ID: <1269845561.2164.1.camel@edumazet-laptop>
References: <20100329174300.512d83a8.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Tom Herbert <therbert@google.com>
To: Stephen Rothwell <sfr@canb.auug.org.au>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20100329174300.512d83a8.sfr@canb.auug.org.au>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le lundi 29 mars 2010 =C3=A0 17:43 +1100, Stephen Rothwell a =C3=A9crit=
 :
> Hi Dave,
>=20
> After merging the final tree, today's linux-next build (powerpc
> ppc44x_defconfig) failed like this:
>=20
> net/core/net-sysfs.c:476: warning: 'struct netdev_rx_queue' declared =
inside parameter list
> net/core/net-sysfs.c:476: warning: its scope is only this definition =
or declaration, which is probably not what you want
> net/core/net-sysfs.c:478: warning: 'struct netdev_rx_queue' declared =
inside parameter list
> net/core/net-sysfs.c: In function 'rx_queue_attr_show':
> net/core/net-sysfs.c:489: error: dereferencing pointer to incomplete =
type
> net/core/net-sysfs.c:489: warning: type defaults to 'int' in declarat=
ion of '__mptr'
> net/core/net-sysfs.c:489: warning: initialization from incompatible p=
ointer type
> net/core/net-sysfs.c:489: error: invalid use of undefined type 'struc=
t netdev_rx_queue'
> net/core/net-sysfs.c:494: warning: passing argument 1 of 'attribute->=
show' from incompatible pointer type
> net/core/net-sysfs.c:494: note: expected 'struct netdev_rx_queue *' b=
ut argument is of type 'struct netdev_rx_queue *'
>=20
> (and many more)
>=20
> Caused by commit 0a9627f2649a02bea165cfd529d7bcb625c2fcad ("rps: Rece=
ive
> Packet Steering") from the net tree.  struct netdev_rx_queue is prote=
cted by
> CONFIG_RPS in netdevice.h, but uses are not so protected in net-sysfs=
=2Ec.
>=20
> I applied the following patch for today:
>=20
> From: Stephen Rothwell <sfr@canb.auug.org.au>
> Date: Mon, 29 Mar 2010 17:27:55 +1100
> Subject: [PATCH] rps: fix net-sysfs build for !CONFIG_RPS
>=20
> Signed-off-by: Stephen Rothwell <sfr@canb.auug.org.au>
> ---
>  net/core/net-sysfs.c |    7 +++++++
>  1 files changed, 7 insertions(+), 0 deletions(-)
>=20
> diff --git a/net/core/net-sysfs.c b/net/core/net-sysfs.c
> index c810042..95af841 100644
> --- a/net/core/net-sysfs.c
> +++ b/net/core/net-sysfs.c
> @@ -467,6 +467,7 @@ static struct attribute_group wireless_group =3D =
{
>  };
>  #endif
> =20
> +#ifdef CONFIG_RPS
>  /*
>   * RX queue sysfs structures and functions.
>   */
> @@ -677,6 +678,12 @@ static void rx_queue_remove_kobjects(struct net_=
device *net)
>  	kset_unregister(net->queues_kset);
>  }
> =20
> +#else /* CONFIG_RPS */
> +
> +static int rx_queue_register_kobjects(struct net_device *net) { retu=
rn 0; }
> +static void rx_queue_remove_kobjects(struct net_device *net) { }
> +
> +#endif /* CONFIG_RPS */
>  #endif /* CONFIG_SYSFS */
> =20
>  #ifdef CONFIG_HOTPLUG
> --=20
> 1.7.0.3


Thats right, this was on my first submission, but I forgot to add
net/core/net-sysfs.c in my second commit, sorry.

Acked-by: Eric Dumazet <eric.dumazet@gmail.com>
