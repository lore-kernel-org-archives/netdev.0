From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH v3.17 .. v3.19] lib/rhashtable: fix race between
 rhashtable_lookup_compare and hashtable resize
Date: Sat, 27 Jun 2015 16:07:43 +0900
Message-ID: <20150627070743.GA29671@gondor.apana.org.au>
References: <20150626104817.16520.77222.stgit@buzz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Stable <stable@vger.kernel.org>,
	David Miller <davem@davemloft.net>, Thomas Graf <tgraf@suug.ch>
To: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Return-path: <stable-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20150626104817.16520.77222.stgit@buzz>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jun 26, 2015 at 01:48:17PM +0300, Konstantin Khlebnikov wrote:
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

This could indeed explain Eric's problems with those kernels.  Eric,
can you rerun your test to see if this patch makes your problem go
away on the pre-4.0 kernels?

Thanks!
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
