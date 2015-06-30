From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH v3.17 .. v3.19] lib/rhashtable: fix race between
 rhashtable_lookup_compare and hashtable resize
Date: Tue, 30 Jun 2015 08:28:36 +0200
Message-ID: <20150630062836.GQ14658@pox.localdomain>
References: <20150626104817.16520.77222.stgit@buzz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Stable <stable@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Return-path: <stable-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20150626104817.16520.77222.stgit@buzz>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 06/26/15 at 01:48pm, Konstantin Khlebnikov wrote:
> Hash value passed as argument into rhashtable_lookup_compare could be
> computed using different hash table than rhashtable_lookup_compare sees.
> 
> This patch passes key into rhashtable_lookup_compare() instead of hash and
> compures hash value right in place using the same table as for lookup.
> 
> Also it adds comment for rhashtable_hashfn and rhashtable_obj_hashfn:
> user must prevent concurrent insert/remove otherwise returned hash value
> could be invalid.
> 
> Signed-off-by: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
> Fixes: e341694e3eb5 ("netlink: Convert netlink_lookup() to use RCU protected hash table")
> Link: http://lkml.kernel.org/r/20150514042151.GA5482@gondor.apana.org.au
> Cc: Stable <stable@vger.kernel.org> (v3.17 .. v3.19)

Nice catch.

For reference, this is a partial cherry pick of
8d24c0b43125e ("rhashtable: Do hashing inside of rhashtable_lookup_compare()")

nft_hash is not affected as it doesn't use the lookup API until 4.0.

Acked-by: Thomas Graf <tgraf@suug.ch>
