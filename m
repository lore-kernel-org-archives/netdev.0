From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 1/1] ATM: mpc, fix use after free
Date: Mon, 11 Oct 2010 10:59:40 +0200
Message-ID: <1286787580.2737.4.camel@edumazet-laptop>
References: <1286785081.2737.2.camel@edumazet-laptop>
	 <1286786794-10410-1-git-send-email-jslaby@suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-atm-general@lists.sourceforge.net,
	linux-kernel@vger.kernel.org, jirislaby@gmail.com
To: Jiri Slaby <jslaby@suse.cz>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1286786794-10410-1-git-send-email-jslaby@suse.cz>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le lundi 11 octobre 2010 =C3=A0 10:46 +0200, Jiri Slaby a =C3=A9crit :
> Stanse found that mpc_push frees skb and then it dereferences it. It
> is a typo, new_skb should be dereferenced there.
>=20
> Signed-off-by: Jiri Slaby <jslaby@suse.cz>
> Cc: Eric Dumazet <eric.dumazet@gmail.com>
> ---
>  net/atm/mpc.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
>=20
> diff --git a/net/atm/mpc.c b/net/atm/mpc.c
> index 622b471..74bcc66 100644
> --- a/net/atm/mpc.c
> +++ b/net/atm/mpc.c
> @@ -778,7 +778,7 @@ static void mpc_push(struct atm_vcc *vcc, struct =
sk_buff *skb)
>  	eg->packets_rcvd++;
>  	mpc->eg_ops->put(eg);
> =20
> -	memset(ATM_SKB(skb), 0, sizeof(struct atm_skb_data));
> +	memset(ATM_SKB(new_skb), 0, sizeof(struct atm_skb_data));
>  	netif_rx(new_skb);
>  }
> =20

Acked-by: Eric Dumazet <eric.dumazet@gmail.com>
