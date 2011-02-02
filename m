From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] ipv4: Remove fib_hash.
Date: Wed, 02 Feb 2011 01:48:13 +0100
Message-ID: <1296607693.2607.7.camel@edumazet-laptop>
References: <20110201.151941.48509941.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:45636 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753867Ab1BBAsX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Feb 2011 19:48:23 -0500
Received: by wwa36 with SMTP id 36so7706175wwa.1
        for <netdev@vger.kernel.org>; Tue, 01 Feb 2011 16:48:22 -0800 (PST)
In-Reply-To: <20110201.151941.48509941.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 01 f=C3=A9vrier 2011 =C3=A0 15:19 -0800, David Miller a =C3=A9=
crit :
> The time has finally come to remove the hash based routing table
> implementation in ipv4.
>=20
> FIB Trie is mature, well tested, and I've done an audit of it's code
> to confirm that it implements insert, delete, and lookup with the sam=
e
> identical semantics as fib_hash did.
>=20
> If there are any semantic differences found in fib_trie, we should
> simply fix them.
>=20
> I've placed the trie statistic config option under advanced router
> configuration.
>=20
> Signed-off-by: David S. Miller <davem@davemloft.net>
> ---

Hmm... I know having to maintain two implementations is time consuming,
but I know fib_trie is bigger :

# size net/ipv4/fib_*.o
   text	   data	    bss	    dec	    hex	filename
   7252	    120	      0	   7372	   1ccc	net/ipv4/fib_frontend.o
   7279	     16	      4	   7299	   1c83	net/ipv4/fib_hash.o
   1479	      0	      0	   1479	    5c7	net/ipv4/fib_rules.o
   7885	      0	   2080	   9965	   26ed	net/ipv4/fib_semantics.o
  16222	     16	     16	  16254	   3f7e	net/ipv4/fib_trie.o

In my tests, I know that fib_trie is more expensive for typical routing
tables for hosts (no more than a dozen or entries), in latencies
results, mostly because of icache misses, but also dcache ones.

Thanks


