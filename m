From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [2.6.36-rc5] INET?: possible irq lock inversion dependency
Date: Wed, 22 Sep 2010 10:34:31 +0200
Message-ID: <1285144471.2639.96.camel@edumazet-laptop>
References: <201006242053.IAG26562.JHQFFOMSVFtOLO@I-love.SAKURA.ne.jp>
	 <201009072132.FHA93457.MHOJFQOOFLVStF@I-love.SAKURA.ne.jp>
	 <201009210651.o8L6pbkP038129@www262.sakura.ne.jp>
	 <1285055760.2617.27.camel@edumazet-laptop>
	 <201009210910.o8L9Anaf071504@www262.sakura.ne.jp>
	 <1285061757.2617.176.camel@edumazet-laptop>
	 <1285064011.2617.238.camel@edumazet-laptop>
	 <201009220714.o8M7Ebps067361@www262.sakura.ne.jp>
	 <1285144306.2639.90.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-fsdevel@vger.kernel.org, netdev@vger.kernel.org
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <1285144306.2639.90.camel@edumazet-laptop>
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le mercredi 22 septembre 2010 =C3=A0 10:31 +0200, Eric Dumazet a =C3=A9=
crit :




> diff --git a/net/core/sock.c b/net/core/sock.c
> index b05b9b6..afd0f69 100644
> --- a/net/core/sock.c
> +++ b/net/core/sock.c
> @@ -1210,7 +1210,9 @@ struct sock *sk_clone(const struct sock *sk, co=
nst gfp_t priority)
>  		spin_lock_init(&newsk->sk_dst_lock);
>  		rwlock_init(&newsk->sk_callback_lock);
>  		lockdep_set_class_and_name(&newsk->sk_callback_lock,
> -				af_callback_keys + newsk->sk_family,
> +				sk->sk_prot->callback_key ?
> +					sk->sk_prot->callback_key :
> +					af_callback_keys + newsk->sk_family,
>  				af_family_clock_key_strings[newsk->sk_family]);
> =20
>  		newsk->sk_dst_cache	=3D NULL;
> @@ -1965,6 +1967,9 @@ void sock_init_data(struct socket *sock, struct=
 sock *sk)
>  	spin_lock_init(&sk->sk_dst_lock);
>  	rwlock_init(&sk->sk_callback_lock);
>  	lockdep_set_class_and_name(&sk->sk_callback_lock,
> +			sk->sk_prot->callback_key ?
> +				sk->sk_prot->callback_key :
> +				af_callback_keys + newsk->sk_family,

small bug in my patch , please delete the orphan line :

>  			af_callback_keys + sk->sk_family,


>  			af_family_clock_key_strings[sk->sk_family]);
> =20


--
To unsubscribe from this list: send the line "unsubscribe linux-fsdevel=
" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
