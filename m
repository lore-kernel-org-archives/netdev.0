From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [6/*] [IPSEC] Fix xfrm[46]_update_pmtu to update top dst
Date: Mon, 7 Mar 2005 21:39:27 +1100
Message-ID: <20050307103927.GA7851@gondor.apana.org.au>
References: <20050214221006.GA18415@gondor.apana.org.au> <20050214221200.GA18465@gondor.apana.org.au> <20050214221433.GB18465@gondor.apana.org.au> <20050214221607.GC18465@gondor.apana.org.au> <20050216103744.GA476@gondor.apana.org.au> <20050216110842.GA1024@gondor.apana.org.au> <20050306213502.1920a99a.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kuznet@ms2.inr.ac.ru, jmorris@redhat.com, yoshfuji@linux-ipv6.org,
        netdev@oss.sgi.com
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20050306213502.1920a99a.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, Mar 06, 2005 at 09:35:02PM -0800, David S. Miller wrote:
> On Wed, 16 Feb 2005 22:08:42 +1100
> Herbert Xu <herbert@gondor.apana.org.au> wrote:
> 
> > Let's also fix IPsec PMTU storage.  When we get an MTU update for an
> > xfrm_dst, it should be done to the top dst, not the bottom dst.
> > 
> > For example, when we get a need-to-frag message for host C behind
> > a our IPsec peer B, we should be updating the dst entry for C and
> > not B as we do now.
> > 
> > I've removed the boundary checks since the same checks are done
> > in ipv[46]/route.c already.
> 
> Note that sometimes it is better to replace an "unnecessary as
> determined by me" boundary check with a BUG() instead of
> outright removal.  That way you get to test your assertion :)

Point taken.  However, I must say that using BUG() in these
two particular places would be fatal :)
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
