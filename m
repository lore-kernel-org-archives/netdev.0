From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH RFC] IPv6: Avoid taking write lock for
 /proc/net/ipv6_route
Date: Fri, 30 Dec 2011 17:09:05 -0500 (EST)
Message-ID: <20111230.170905.1348056803377924696.davem@davemloft.net>
References: <CAKA=qzbZ4x5u1bBM0gAECeMNutyaVzp1FmRPwKHsBEEs7984ag@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: joshhunt00@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAKA=qzbZ4x5u1bBM0gAECeMNutyaVzp1FmRPwKHsBEEs7984ag@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Josh Hunt <joshhunt00@gmail.com>
Date: Wed, 28 Dec 2011 17:23:07 -0600

> lock_stat shows taking the write lock is causing the slowdown. Using
> this info I decided to write a version of fib6_clean_all() which
> replaces write_lock_bh(&table->tb6_lock) with
> read_lock_bh(&table->tb6_lock). With this new function I see the same
> results as with my rtnetlink iperf test. I guess my question is what
> am I missing? Is there a reason you need to take the write lock when
> reading the route table to display to proc?

You're not missing anything, it's just an oversight or laziness. :-)

I've applied your patch thanks.

Longer term we should make the ipv6 tree traversals RCU safe just
like net/ipv4/fib_trie.c is.  Then we can do away with even the
read locks for read-only traversals.
