From: Josh Hunt <joshhunt00@gmail.com>
Subject: Re: [PATCH RFC] IPv6: Avoid taking write lock for /proc/net/ipv6_route
Date: Sat, 31 Dec 2011 13:49:38 -0600
Message-ID: <CAKA=qzb=PYTMO=9KFpTJ9BVdDRkqbaCuW02pbW0onM8gU1E7sw@mail.gmail.com>
References: <CAKA=qzbZ4x5u1bBM0gAECeMNutyaVzp1FmRPwKHsBEEs7984ag@mail.gmail.com>
	<20111230.170905.1348056803377924696.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20111230.170905.1348056803377924696.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Dec 30, 2011 at 4:09 PM, David Miller <davem@davemloft.net> wro=
te:
> From: Josh Hunt <joshhunt00@gmail.com>
> Date: Wed, 28 Dec 2011 17:23:07 -0600
>
>> lock_stat shows taking the write lock is causing the slowdown. Using
>> this info I decided to write a version of fib6_clean_all() which
>> replaces write_lock_bh(&table->tb6_lock) with
>> read_lock_bh(&table->tb6_lock). With this new function I see the sam=
e
>> results as with my rtnetlink iperf test. I guess my question is what
>> am I missing? Is there a reason you need to take the write lock when
>> reading the route table to display to proc?
>
> You're not missing anything, it's just an oversight or laziness. :-)
>
> I've applied your patch thanks.
>
> Longer term we should make the ipv6 tree traversals RCU safe just
> like net/ipv4/fib_trie.c is. =A0Then we can do away with even the
> read locks for read-only traversals.
>

Thanks David. Are you aware if anyone has started the work to make
IPv6 traversals RCU safe?
--=20
Josh
