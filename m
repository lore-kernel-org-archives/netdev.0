From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH]: inet_diag: Missed conversion after changing inet ehash
 lockl to spinlocks.
Date: Sat, 22 Nov 2008 07:52:04 +0100
Message-ID: <4927AC14.3030702@cosmosbay.com>
References: <20081121.164013.199583439.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([86.65.150.130]:59626 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751871AbYKVGwK convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 22 Nov 2008 01:52:10 -0500
In-Reply-To: <20081121.164013.199583439.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller a =E9crit :
> Tsk tsk... :) I just commited the following to net-next-2.6

Oops, thanks David.

>=20
> inet_diag: Missed conversion after changing inet ehash lockl to spinl=
ocks.
>=20
> They are no longer a rwlocks.
>=20
> Signed-off-by: David S. Miller <davem@davemloft.net>
> ---
>  net/ipv4/inet_diag.c |   10 +++++-----
>  1 files changed, 5 insertions(+), 5 deletions(-)
>=20
> diff --git a/net/ipv4/inet_diag.c b/net/ipv4/inet_diag.c
> index 1cb154e..998a78f 100644
> --- a/net/ipv4/inet_diag.c
> +++ b/net/ipv4/inet_diag.c
> @@ -778,7 +778,7 @@ skip_listen_ht:
> =20
>  	for (i =3D s_i; i < hashinfo->ehash_size; i++) {
>  		struct inet_ehash_bucket *head =3D &hashinfo->ehash[i];
> -		rwlock_t *lock =3D inet_ehash_lockp(hashinfo, i);
> +		spinlock_t *lock =3D inet_ehash_lockp(hashinfo, i);
>  		struct sock *sk;
>  		struct hlist_nulls_node *node;
> =20
> @@ -791,7 +791,7 @@ skip_listen_ht:
>  		if (i > s_i)
>  			s_num =3D 0;
> =20
> -		read_lock_bh(lock);
> +		spin_lock_bh(lock);
>  		sk_nulls_for_each(sk, node, &head->chain) {
>  			struct inet_sock *inet =3D inet_sk(sk);
> =20
> @@ -806,7 +806,7 @@ skip_listen_ht:
>  			    r->id.idiag_dport)
>  				goto next_normal;
>  			if (inet_csk_diag_dump(sk, skb, cb) < 0) {
> -				read_unlock_bh(lock);
> +				spin_unlock_bh(lock);
>  				goto done;
>  			}
>  next_normal:
> @@ -828,14 +828,14 @@ next_normal:
>  				    r->id.idiag_dport)
>  					goto next_dying;
>  				if (inet_twsk_diag_dump(tw, skb, cb) < 0) {
> -					read_unlock_bh(lock);
> +					spin_unlock_bh(lock);
>  					goto done;
>  				}
>  next_dying:
>  				++num;
>  			}
>  		}
> -		read_unlock_bh(lock);
> +		spin_unlock_bh(lock);
>  	}
> =20
>  done:


