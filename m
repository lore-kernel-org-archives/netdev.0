From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] UDPCP Communication Protocol
Date: Fri, 31 Dec 2010 12:25:58 +0100
Message-ID: <1293794758.2973.49.camel@edumazet-laptop>
References: <1293787785-3834-1-git-send-email-stefani@seibold.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org,
	davem@davemloft.net, netdev@vger.kernel.org
To: stefani@seibold.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1293787785-3834-1-git-send-email-stefani@seibold.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le vendredi 31 d=C3=A9cembre 2010 =C3=A0 10:29 +0100, stefani@seibold.n=
et a
=C3=A9crit :
> +		if (!list_empty(&usk->destlist)) {
> +			state->sk =3D (struct sock *)usk;
> +			state->dest =3D list_first_entry(&usk->destlist,
> +					struct udpcp_dest, list);
> +			sock_hold(state->sk);
> +
> +			if (atomic_read(&state->sk->sk_refcnt) !=3D 1) {
> +				spin_unlock_irqrestore(&spinlock, flags);
> +				return state;
> +			}
> +			atomic_dec(&state->sk->sk_refcnt);
> +		}
> +

I am trying to understand what you are doing here.

It seems racy to me.

Apparently, what you want is to take a reference only if actual
sk_refcnt is not zero.

I suggest using atomic_inc_notzero(&state->sk->sk_refcnt) to avoid the
race in atomic_dec().
