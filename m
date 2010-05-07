From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: TCP-MD5 checksum failure on x86_64 SMP
Date: Fri, 07 May 2010 07:32:09 +0200
Message-ID: <1273210329.2222.42.camel@edumazet-laptop>
References: <1273085598.2367.233.camel@edumazet-laptop>
	 <i2y571fb4001005060455m39bed7f7if5fcfc45b12bc4d3@mail.gmail.com>
	 <1273147586.2357.63.camel@edumazet-laptop>
	 <20100506.220443.135536330.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: bhaskie@gmail.com, shemminger@vyatta.com,
	bhutchings@solarflare.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f219.google.com ([209.85.218.219]:61653 "EHLO
	mail-bw0-f219.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751752Ab0EGFcO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 May 2010 01:32:14 -0400
Received: by bwz19 with SMTP id 19so370005bwz.21
        for <netdev@vger.kernel.org>; Thu, 06 May 2010 22:32:13 -0700 (PDT)
In-Reply-To: <20100506.220443.135536330.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 06 mai 2010 =C3=A0 22:04 -0700, David Miller a =C3=A9crit :
> From: Eric Dumazet <eric.dumazet@gmail.com>

> > This code should be completely rewritten for linux-2.6.35, its very=
 ugly
> > and over complex, yet it is not scalable.
> >=20
> > It could use true percpu data, with no central lock or refcount.
>=20
> Yes I've always disliked the way the TCP MD5 pool stuff is coded, it'=
s
> frankly crap and this is like the 5th major bug that had to get fixed
> in it. :-)
>=20
> But let's fix this as simply as possible in net-2.6 and -stable, so E=
ric
> let me know when you have a tested patch for me to apply.

There are so many things ...

I am comtemplating commit aa133076

__tcp_alloc_md5sig_pool() now do a :=20

p =3D kzalloc(sizeof(*p), sk->sk_allocation);

But later call :

hash =3D crypto_alloc_hash("md5", 0, CRYPTO_ALG_ASYNC);

(GFP_KERNEL allocations for sure)


tcp_v4_parse_md5_keys() also use :

p =3D kzalloc(sizeof(*p), sk->sk_allocation);

right after a (possibly sleeping) copy_from_user()

Oh well...


I'll test the already suggested patch before official submission,
thanks.



