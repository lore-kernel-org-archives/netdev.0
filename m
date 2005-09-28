From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [RFC][PATCH] identify in_dev_get rcu read-side critical sections
Date: Wed, 28 Sep 2005 12:55:45 +1000
Message-ID: <E1EKS6j-0006s4-00__7099.60353929109$1127876548$gmane$org@gondolin.me.apana.org.au>
References: <20050927.135626.88296134.davem@davemloft.net>
Cc: suzannew@cs.pdx.edu, linux-kernel@vger.kernel.org,
        Robert.Olsson@data.slu.se, paulmck@us.ibm.com, walpole@cs.pdx.edu,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@davemloft.net (David S. Miller)
In-Reply-To: <20050927.135626.88296134.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

David S. Miller <davem@davemloft.net> wrote:
> 
> I agree with the changes to add rcu_dereference() use.
> Those were definitely lacking and needed.

Actually I'm not so sure that they are all needed.  I only looked
at the very first one in the patch which is in in_dev_get().  That
one certainly isn't necessary because the old value of ip_ptr
is valid as long as the reference count does not hit zero.

The later is guaranteed by the increment in in_dev_get().

Because the pervasiveness of reference counting in the network stack,
I believe that we should scrutinise the other bits in the patch too
to make sure that they are all needed.

In general, using rcu_dereference/rcu_assign_pointer does not
guarantee correct code.  We really need to look at each case
individually.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
