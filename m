From: Christoph Lameter <christoph@lameter.com>
Subject: Re: atomic_dec_and_test for child dst needed in dst_destroy?
Date: Tue, 5 Apr 2005 15:14:26 -0700 (PDT)
Message-ID: <Pine.LNX.4.58.0504051507250.17203@server.graphe.net>
References: <E1DIvr8-0002yy-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com, davem@davemloft.net
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <E1DIvr8-0002yy-00@gondolin.me.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 6 Apr 2005, Herbert Xu wrote:

> > -               if (atomic_dec_and_test(&dst->__refcnt)) {
> > +               atomic_dec(&dst->__refcnt);
> > +               if (!atomic_read(&dst->__refcnt)) {
>
> This is racy (albeit very unlikely) because dst may be freed by
> dst_run_gc after the atomic_dec.

If that is so then it is also possible that the gc frees after
atomic_dec_and_test:

cpu0 dst_destroy	cpu1 dst_run_gc

atomic_dec_and_test(refcnt)
			if (atomic_read(refcnt)) ...
			..
			dst_destroy(dst)
			kmem_cache_free(dst)
..
goto again
...
kmem_cache_free(dst)
