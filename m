From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [patch] do not readlock all buckets in /proc/net/tcp
Date: Mon, 05 Jul 2004 21:27:54 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <E1BhRda-0001Rs-00@gondolin.me.apana.org.au>
References: <20040705110949.GA1092@suse.de>
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: meissner@suse.de (Marcus Meissner)
In-Reply-To: <20040705110949.GA1092@suse.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Marcus Meissner <meissner@suse.de> wrote:
> 
> This patch makes the files /proc/net/tcp and /proc/net/tcp6 not acquire
> the readlock for every bucket.
> 
> On ppc64 and ia64 the readlocks are so expensive, that reading /proc/net/tcp
> takes 0.25 seconds on a usual p670 LPAR.
> 
> And it locks 65536 buckets where just 20 chains are used at all in a normal
> non-netserver setup.

Why not use NETLINK+TCP_DIAG instead? It's much faster.
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
