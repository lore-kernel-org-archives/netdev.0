From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH net] netlink: use jhash as hashfn for rhashtable
Date: Mon, 8 Dec 2014 16:38:02 +0000
Message-ID: <20141208163802.GC9831@casper.infradead.org>
References: <1418056230-8700-1-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:51722 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754822AbaLHQiE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Dec 2014 11:38:04 -0500
Content-Disposition: inline
In-Reply-To: <1418056230-8700-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/08/14 at 05:30pm, Daniel Borkmann wrote:
> For netlink, we shouldn't be using arch_fast_hash() as a hashing
> discipline, but rather jhash() instead.
> 
> Since netlink sockets can be opened by any user, a local attacker
> would be able to easily create collisions with the DPDK-derived
> arch_fast_hash(), which trades off performance for security by
> using crc32 CPU instructions on x86_64.
> 
> While it might have a legimite use case in other places, it should
> be avoided in netlink context, though. As rhashtable's API is very
> flexible, we could later on still decide on other hashing disciplines,
> if legitimate.
> 
> Reference: http://thread.gmane.org/gmane.linux.kernel/1844123
> Fixes: e341694e3eb5 ("netlink: Convert netlink_lookup() to use RCU protected hash table")
> Cc: Herbert Xu <herbert@gondor.apana.org.au>
> Cc: Thomas Graf <tgraf@suug.ch>
> Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>
> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>

Acked-by: Thomas Graf <tgraf@suug.ch>
