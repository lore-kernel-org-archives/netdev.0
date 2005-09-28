From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [RFC][PATCH] identify in_dev_get rcu read-side critical sections
Date: Thu, 29 Sep 2005 08:11:10 +1000
Message-ID: <20050928221110.GA22018__39156.0719618157$1127946112$gmane$org@gondor.apana.org.au>
References: <20050927.135626.88296134.davem@davemloft.net> <E1EKS6j-0006s4-00@gondolin.me.apana.org.au> <20050928145110.GA4925@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, suzannew@cs.pdx.edu,
        linux-kernel@vger.kernel.org, Robert.Olsson@data.slu.se,
        walpole@cs.pdx.edu, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "Paul E. McKenney" <paulmck@us.ibm.com>
Content-Disposition: inline
In-Reply-To: <20050928145110.GA4925@us.ibm.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, Sep 28, 2005 at 07:51:10AM -0700, Paul E. McKenney wrote:
> 
> The reference-count approach is only guaranteed to work if the kernel
> thread that did the reference-count increment is later referencing that
> same data element.  Otherwise, one has the following possible situation
> on DEC Alpha:

You're quite right.  Without the rcu_dereference users of in_dev_get()
may see pre-initialisation contents of in_dev.

So these barriers are definitely needed.

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
