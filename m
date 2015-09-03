From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3] net: Fix behaviour of unreachable, blackhole and
 prohibit routes
Date: Thu, 03 Sep 2015 10:31:09 -0700 (PDT)
Message-ID: <20150903.103109.1102527875442650781.davem@davemloft.net>
References: <1441274722.3360.59.camel@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: nforro@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44940 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751592AbbICRbK convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Sep 2015 13:31:10 -0400
In-Reply-To: <1441274722.3360.59.camel@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Nikola Forr=F3 <nforro@redhat.com>
Date: Thu, 03 Sep 2015 12:05:22 +0200

> @@ -233,8 +233,11 @@ static inline int fib_lookup(struct net *net, co=
nst struct flowi4 *flp,
>  	rcu_read_lock();
> =20
>  	tb =3D fib_get_table(net, RT_TABLE_MAIN);
> -	if (tb && !fib_table_lookup(tb, flp, res, flags | FIB_LOOKUP_NOREF)=
)
> -		err =3D 0;
> +	if (tb) {
> +		err =3D fib_table_lookup(tb, flp, res, flags | FIB_LOOKUP_NOREF);
> +		if (err =3D=3D -EAGAIN)
> +			err =3D -ENETUNREACH;
> +	}
> =20

You resubmitted this so quickly, there is no way you did any testing
of this code path even after fixing up the curly brace issue.
