From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH] net: netfilter: fix GCC uninitialized warning
Date: Fri, 6 Nov 2015 20:10:08 +0100
Message-ID: <20151106191008.GA2362@salvia>
References: <1446835694-6967-1-git-send-email-0x7f454c46@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: kaber@trash.net, kadlec@blackhole.kfki.hu, davem@davemloft.net,
	netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Dmitry Safonov <0x7f454c46@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1446835694-6967-1-git-send-email-0x7f454c46@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Nov 06, 2015 at 09:48:14PM +0300, Dmitry Safonov wrote:
> With x86_64_defconfig:
> GCC thinks that in nfulnl_recv_config flags parameter is not inited b=
ut
> it was under the same condition (nfula[NFULA_CFG_FLAGS] =3D=3D true).
> Suppress this warning:
> 	net/netfilter/nfnetlink_log.c: In function =E2=80=98nfulnl_recv_conf=
ig=E2=80=99:
> 	net/netfilter/nfnetlink_log.c:320:14: warning: =E2=80=98flags=E2=80=99=
 may be used uninitialized in this function [-Wmaybe-uninitialized]
>   	inst->flags =3D flags;
> 	            ^
> Signed-off-by: Dmitry Safonov <0x7f454c46@gmail.com>
> ---
>  net/netfilter/nfnetlink_log.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>=20
> diff --git a/net/netfilter/nfnetlink_log.c b/net/netfilter/nfnetlink_=
log.c
> index 06eb48fceb42e4..d65f3b987b7f13 100644
> --- a/net/netfilter/nfnetlink_log.c
> +++ b/net/netfilter/nfnetlink_log.c
> @@ -825,7 +825,7 @@ nfulnl_recv_config(struct sock *ctnl, struct sk_b=
uff *skb,
>  	struct net *net =3D sock_net(ctnl);
>  	struct nfnl_log_net *log =3D nfnl_log_pernet(net);
>  	int ret =3D 0;
> -	u16 flags;
> +	u16 flags =3D 0; /* GCC uninitialized */

        u16 uninitialized_var(flags); ?

>  	if (nfula[NFULA_CFG_CMD]) {
>  		u_int8_t pf =3D nfmsg->nfgen_family;
> --=20
> 2.6.2
>=20
