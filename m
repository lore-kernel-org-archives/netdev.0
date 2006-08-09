From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH 2/2] [IPV4] route: Dynamic hash table sizing.
Date: Wed, 9 Aug 2006 12:09:28 +0200
Message-ID: <200608091209.29231.dada1@cosmosbay.com>
References: <20060809.004920.59469729.davem@davemloft.net> <20060809.005337.104642177.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from pfx2.jmh.fr ([194.153.89.55]:40895 "EHLO pfx2.jmh.fr")
	by vger.kernel.org with ESMTP id S1030583AbWHIKJa convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Aug 2006 06:09:30 -0400
To: David Miller <davem@davemloft.net>
In-Reply-To: <20060809.005337.104642177.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wednesday 09 August 2006 09:53, David Miller wrote:

> +	if (atomic_read(&ipv4_dst_ops.entries) >=3D (hmask + 1) &&
> +	    (hmask + 1) < ip_rt_hashsz_limit)
> +		schedule_work(&rtcache_work);
> +	return 0;
>  }
>

I wonder if you should not replicate this test (against (hmask + 1) <=20
ip_rt_hashsz_limit) in rtcache_resize() itself, because we might end ca=
lling=20
rthash_new_size() while (hmask +1 ) =3D ip_rt_hashsz_limit

> -=A0=A0=A0=A0=A0=A0=A0mult =3D ((u64)ip_rt_gc_interval) << long_log2(=
hmask + 1);
> +=A0=A0=A0=A0=A0=A0=A0mult =3D ((u64)(hmask + 1)) << (u64)ip_rt_gc_in=
terval;

Not sure I understand what you did here (in rt_check_expire()), could y=
ou=20
please explain the math ? (I may be wrong but (x * 2^y) !=3D (y * 2^x) =
for=20
general values of x and y)

Eric
