From: Marcus Meissner <meissner@suse.de>
Subject: Re: [patch] do not readlock all buckets in /proc/net/tcp
Date: Mon, 5 Jul 2004 13:35:55 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040705113555.GA28665@suse.de>
References: <20040705110949.GA1092@suse.de> <E1BhRda-0001Rs-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
Content-Disposition: inline
In-Reply-To: <E1BhRda-0001Rs-00@gondolin.me.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, Jul 05, 2004 at 09:27:54PM +1000, Herbert Xu wrote:
> Marcus Meissner <meissner@suse.de> wrote:
> > 
> > This patch makes the files /proc/net/tcp and /proc/net/tcp6 not acquire
> > the readlock for every bucket.
> > 
> > On ppc64 and ia64 the readlocks are so expensive, that reading /proc/net/tcp
> > takes 0.25 seconds on a usual p670 LPAR.
> > 
> > And it locks 65536 buckets where just 20 chains are used at all in a normal
> > non-netserver setup.
> 
> Why not use NETLINK+TCP_DIAG instead? It's much faster.

Not sure if you want / can fix all proprietary software.

Oh, and NETLINK+TCP_DIAG seems to have the same readlock contention problem,
see tcpdiag_dump().

Ciao, Marcus
