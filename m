From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] net: Fix behaviour of unreachable, blackhole and
 prohibit routes
Date: Thu, 03 Sep 2015 10:29:55 -0700 (PDT)
Message-ID: <20150903.102955.927476775467830647.davem@davemloft.net>
References: <1441271331.3360.36.camel@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: nforro@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44931 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751587AbbICR35 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Sep 2015 13:29:57 -0400
In-Reply-To: <1441271331.3360.36.camel@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Nikola Forr=F3 <nforro@redhat.com>
Date: Thu, 03 Sep 2015 11:08:51 +0200

> @@ -233,8 +233,10 @@ static inline int fib_lookup(struct net *net, co=
nst struct flowi4 *flp,
>  	rcu_read_lock();
> =20
>  	tb =3D fib_get_table(net, RT_TABLE_MAIN);
> -	if (tb && !fib_table_lookup(tb, flp, res, flags | FIB_LOOKUP_NOREF)=
)
> -		err =3D 0;
> +	if (tb)
> +		err =3D fib_table_lookup(tb, flp, res, flags | FIB_LOOKUP_NOREF);
> +		if (err =3D=3D -EAGAIN)
> +			err =3D -ENETUNREACH;

You didn't test this.
