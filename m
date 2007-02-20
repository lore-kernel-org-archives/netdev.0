From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: Extensible hashing and RCU
Date: Tue, 20 Feb 2007 11:49:59 +0100
Message-ID: <200702201150.00396.dada1@cosmosbay.com>
References: <200702191913.08125.dada1@cosmosbay.com> <200702201104.16200.dada1@cosmosbay.com> <20070220.021209.39159087.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: johnpol@2ka.mipt.ru, akepner@sgi.com, linux@horizon.com,
	netdev@vger.kernel.org, bcrl@kvack.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pfx2.jmh.fr ([194.153.89.55]:39061 "EHLO pfx2.jmh.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932871AbXBTKuK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Feb 2007 05:50:10 -0500
In-Reply-To: <20070220.021209.39159087.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tuesday 20 February 2007 11:12, David Miller wrote:
> From: Eric Dumazet <dada1@cosmosbay.com>
> Date: Tue, 20 Feb 2007 11:04:15 +0100
>
> > Using a jenkin's hash permits a better hash distribution for a litle
> > cpu cost.  I will post later a distribution simulation based on the
> > data gathered from the same real server.
>
> Actually someone (I think it was Evgeniy in fact) made such
> comparisons and found in his studies that not only does the current
> ehash xor hash function distribute about as well as jenkins, it's
> significantly cheaper to calculate :-)
>
> If you find jenkins is better, great, but I hope it works that
> way for many workloads.

Here are results from real workload :

ehash_addr=0xffff810476000000
ehash_size=1048576
330241 chains, 2441 twchains
Distribution of sockets/chain length
[chain length]:number of sockets
[0]:718335 0%
[1]:223485 42.1436%
[2]:60655 65.0196%
[3]:22451 77.7207%
[4]:11164 86.1416%
[5]:6376 92.1534%
[6]:3236 95.8148%
[7]:1600 97.9268%
[8]:793 99.1231%
[9]:286 99.6085%
[10]:111 99.8178%
[11]:56 99.934%
[12]:20 99.9793%
[13]:4 99.9891%
[14]:2 99.9943%
[15]:2 100%
total : 530294 sockets


Imagine we double hash size (2097152). Distribution would be:
[0]:1698209 0%
[1]:309255 58.3177%
[2]:61638 81.5644%
[3]:18593 92.0829%
[4]:6479 96.97%
[5]:2092 98.9425%
[6]:655 99.6836%
[7]:184 99.9265%
[8]:37 99.9823%
[9]:6 99.9925%
[10]:4 100%

If we use jenkin hash: jhash_3words(daddr, saddr, (dport<<16)|sport, 0);

[0]:632435 0%
[1]:319916 60.328%
[2]:80465 90.6754%
[3]:13816 98.4914%
[4]:1735 99.8001%
[5]:196 99.9849%
[6]:11 99.9974%
[7]:2 100%

