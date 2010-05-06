From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] ipv4: remove ip_rt_secret timer (v2)
Date: Thu, 06 May 2010 23:08:05 +0200
Message-ID: <1273180085.2222.33.camel@edumazet-laptop>
References: <20100506171639.GA5063@hmsreliant.think-freely.org>
	 <20100506202957.GE5063@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net, kuznet@ms2.inr.ac.ru,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f219.google.com ([209.85.218.219]:65057 "EHLO
	mail-bw0-f219.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751630Ab0EFVIL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 May 2010 17:08:11 -0400
Received: by bwz19 with SMTP id 19so243051bwz.21
        for <netdev@vger.kernel.org>; Thu, 06 May 2010 14:08:09 -0700 (PDT)
In-Reply-To: <20100506202957.GE5063@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 06 mai 2010 =C3=A0 16:29 -0400, Neil Horman a =C3=A9crit :
> Version 2 of this patch, taking Erics comment about making the rt_gen=
id non-zero
> when a netns is created.  This makes sense, and helps prevent attacke=
rs from
> guessing our initial secret value
>=20
>=20
>=20
> A while back there was a discussion regarding the rt_secret_interval =
timer.
> Given that we've had the ability to do emergency route cache rebuilds=
 for awhile
> now, based on a statistical analysis of the various hash chain length=
s in the
> cache, the use of the flush timer is somewhat redundant.  This patch =
removes the
> rt_secret_interval sysctl, allowing us to rely solely on the statisti=
cal
> analysis mechanism to determine the need for route cache flushes.
>=20
> Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
>=20

> -
> -static __net_init int rt_secret_timer_init(struct net *net)
> +static __net_init int rt_genid_init(struct net *net)
>  {
> -	atomic_set(&net->ipv4.rt_genid,
> -			(int) ((num_physpages ^ (num_physpages>>8)) ^
> -			(jiffies ^ (jiffies >> 7))));
> -


> +	/*
> +	 * This just serves to start off each new net namespace
> +	 * with a non-zero rt_genid value, making it harder to guess
> +	 */
> +	rt_cache_invalidate(net);
>  	return 0;
>  }
> =20

I am _sorry_ to be such a paranoiac guy.

Could you please feed more than 8 bits here ?

like :

get_random_bytes(&net->ipv4.rt_genid, sizeof(net->ipv4.rt_genid));

There is no need to comment this in the code, this kind of rnd init is
very common in net tree.





