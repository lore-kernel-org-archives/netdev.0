From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [RFC][PATCH] identify in_dev_get rcu read-side critical sections
Date: Fri, 30 Sep 2005 07:28:36 +1000
Message-ID: <20050929212836.GA14323__36418.1229299449$1128029773$gmane$org@gondor.apana.org.au>
References: <200509291602.j8TG2TuI015920@rastaban.cs.pdx.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: paulmck@us.ibm.com, Robert.Olsson@data.slu.se, davem@davemloft.net,
        linux-kernel@vger.kernel.org, netdev@oss.sgi.com, walpole@cs.pdx.edu
Return-path: <netdev-bounce@oss.sgi.com>
To: Suzanne Wood <suzannew@cs.pdx.edu>
Content-Disposition: inline
In-Reply-To: <200509291602.j8TG2TuI015920@rastaban.cs.pdx.edu>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, Sep 29, 2005 at 09:02:29AM -0700, Suzanne Wood wrote:
> 
> The exchange below suggests that it is equally important 
> to have the rcu_dereference() in __in_dev_get(), so the 
> idea of the only difference between in_dev_get and 
> __in_dev_get being the refcnt may be accepted.

With __in_dev_get() it's the caller's responsibility to ensure
that RCU works correctly.  Therefore if any rcu_dereference is
needed it should be done by the caller.

Some callers of __in_dev_get() don't need rcu_dereference at all
because they're protected by the rtnl.

BTW, could you please move the rcu_dereference in in_dev_get()
into the if clause? The barrier is not needed when ip_ptr is
NULL.

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
