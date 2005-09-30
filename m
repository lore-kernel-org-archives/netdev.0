From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [RFC][PATCH] identify in_dev_get rcu read-side critical sections
Date: Fri, 30 Sep 2005 10:21:44 +1000
Message-ID: <20050930002144.GA21062@gondor.apana.org.au>
References: <200509292330.j8TNUSmH019572@rastaban.cs.pdx.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Robert.Olsson@data.slu.se, davem@davemloft.net,
        linux-kernel@vger.kernel.org, netdev@oss.sgi.com, paulmck@us.ibm.com,
        walpole@cs.pdx.edu
Return-path: <netdev-bounce@oss.sgi.com>
To: Suzanne Wood <suzannew@cs.pdx.edu>
Content-Disposition: inline
In-Reply-To: <200509292330.j8TNUSmH019572@rastaban.cs.pdx.edu>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, Sep 29, 2005 at 04:30:28PM -0700, Suzanne Wood wrote:
> 
> > BTW, could you please move the rcu_dereference in in_dev_get()
> > into the if clause? The barrier is not needed when ip_ptr is
> > NULL.
> 
> The trouble with that may be that there are three events, the
> dereference, the assignment, and the conditional test.  The
> rcu_dereference() is meant to assure deferred destruction
> throughout.

The deferred destruction is guaranteed here by the reference count.
The only purpose served by rcu_dereference() in in_dev_get() is to
prevent the user from seeing pre-initialisation data.

When the pointer is NULL, you can't see any data at all, let alone
pre-initialisation data.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
