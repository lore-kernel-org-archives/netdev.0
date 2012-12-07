From: Cong Ding <dinggnu@gmail.com>
Subject: Re: [PATCH] net: core: fix unused variable sparse warning
Date: Fri, 7 Dec 2012 00:15:47 +0000
Message-ID: <20121207001545.GE2510@gmail.com>
References: <1354838913-20084-1-git-send-email-dinggnu@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: "David S. Miller" <davem@davemloft.net>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Eric Dumazet <edumazet@google.com>,
	Pavel Emelyanov <xemul@parallels.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1354838913-20084-1-git-send-email-dinggnu@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Dec 07, 2012 at 12:06:44AM +0000, Cong Ding wrote:
> the variables zero and unres_qlen_max are only used when CONFIG_SYSCT=
L is
> defined, otherwise it causes the following sparse warning when we tur=
n on
> CONFIG_SYSCTL.
sorry for disturbing again, the sparse warning is
net/core/neighbour.c:65:12: warning: =E2=80=98zero=E2=80=99 defined but=
 not used [-Wunused-variable]
net/core/neighbour.c:66:12: warning: =E2=80=98unres_qlen_max=E2=80=99 d=
efined but not used [-Wunused-variable]

it happens if we turn off CONFIG_SYSCTL.

>=20
> Signed-off-by: Cong Ding <dinggnu@gmail.com>
> ---
>  net/core/neighbour.c |    2 ++
>  1 files changed, 2 insertions(+), 0 deletions(-)
>=20
> diff --git a/net/core/neighbour.c b/net/core/neighbour.c
> index 36fc692..4a15278 100644
> --- a/net/core/neighbour.c
> +++ b/net/core/neighbour.c
> @@ -62,8 +62,10 @@ static void __neigh_notify(struct neighbour *n, in=
t type, int flags);
>  static void neigh_update_notify(struct neighbour *neigh);
>  static int pneigh_ifdown(struct neigh_table *tbl, struct net_device =
*dev);
> =20
> +#ifdef CONFIG_SYSCTL
>  static int zero;
>  static int unres_qlen_max =3D INT_MAX / SKB_TRUESIZE(ETH_FRAME_LEN);
> +#endif
> =20
>  static struct neigh_table *neigh_tables;
>  #ifdef CONFIG_PROC_FS
> --=20
> 1.7.4.5
>=20
