From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] IPVS: logging sizeof(struct ip_vs_conn) on startup
Date: Mon, 27 Jul 2009 11:25:25 +0200
Message-ID: <4A6D7285.9080909@gmail.com>
References: <20090727090741.16509.35291.stgit@jazzy.zrh.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, lvs-users@linuxvirtualserver.org,
	malcolm@loadbalancer.org, linux-kernel@vger.kernel.org
To: Hannes Eder <heder@google.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755890AbZG0JZf@vger.kernel.org>
In-Reply-To: <20090727090741.16509.35291.stgit@jazzy.zrh.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hannes Eder a =C3=A9crit :
> No more guessing, how much memory is used by IPVS for a connection.
>=20
> Signed-off-by: Hannes Eder <heder@google.com>
> ---
>  net/netfilter/ipvs/ip_vs_core.c |    3 ++-
>  1 files changed, 2 insertions(+), 1 deletions(-)
>=20
> diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_=
vs_core.c
> index b021464..5b0997c 100644
> --- a/net/netfilter/ipvs/ip_vs_core.c
> +++ b/net/netfilter/ipvs/ip_vs_core.c
> @@ -1475,7 +1475,8 @@ static int __init ip_vs_init(void)
>  		goto cleanup_conn;
>  	}
> =20
> -	IP_VS_INFO("ipvs loaded.\n");
> +	IP_VS_INFO("ipvs loaded (using %Zd bytes/connection).\n",
> +	       sizeof(struct ip_vs_conn));
>  	return ret;
> =20
>    cleanup_conn:

Well, ip_vs_conn_cache uses SLAB_HWCACHE_ALIGN, so this should be round=
ed up
to L1 cache size. Or add "at least" like in line 1080
of net/netfilter/ipvs/ip_vs_conn.c :

	IP_VS_DBG(0, "Each connection entry needs %Zd bytes at least\n",
		  sizeof(struct ip_vs_conn));
