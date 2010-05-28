From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: fn_trie_lookup and fn_hash_lookup
Date: Thu, 27 May 2010 20:40:55 -0700
Message-ID: <20100527204055.406343eb@nehalam>
References: <AANLkTikmIzPaOKdlXtCwosfJXzaKY1vxib_MdqI0vN_5@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net@vger.kernel.org
To: ratheesh k <ratheesh.ksz@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:49426 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754443Ab0E1DlG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 May 2010 23:41:06 -0400
In-Reply-To: <AANLkTikmIzPaOKdlXtCwosfJXzaKY1vxib_MdqI0vN_5@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 28 May 2010 08:53:11 +0530
ratheesh k <ratheesh.ksz@gmail.com> wrote:

> hi ,
> 
> I was looking into 2.6.18 kernel . I can see two functions
> fn_trie_lookup , fn_hash_lookup
> 
> ipv4/fib_trie.c:	tb->tb_lookup = fn_trie_lookup;
> ipv4/fib_hash.c:	tb->tb_lookup = fn_hash_lookup;
> 
> What is the differnce between these two functions ?

They are the two possible FIB algorithms configurable.

net/ipv4/Kconfig:

choice
	prompt "Choose IP: FIB lookup algorithm (choose FIB_HASH if unsure)"
	depends on IP_ADVANCED_ROUTER
	default ASK_IP_FIB_HASH

config ASK_IP_FIB_HASH
	bool "FIB_HASH"
	---help---
	  Current FIB is very proven and good enough for most users.

config IP_FIB_TRIE
	bool "FIB_TRIE"
	---help---
	  Use new experimental LC-trie as FIB lookup algorithm.
	  This improves lookup performance if you have a large
	  number of routes.

	  LC-trie is a longest matching prefix lookup algorithm which
	  performs better than FIB_HASH for large routing tables.
	  But, it consumes more memory and is more complex.

	  LC-trie is described in:

	  IP-address lookup using LC-tries. Stefan Nilsson and Gunnar Karlsson
	  IEEE Journal on Selected Areas in Communications, 17(6):1083-1092,
	  June 1999

	  An experimental study of compression methods for dynamic tries
	  Stefan Nilsson and Matti Tikkanen. Algorithmica, 33(1):19-33, 2002.
	  http://www.nada.kth.se/~snilsson/public/papers/dyntrie2/


Also see Documentation/networking/fib_trie.txt


