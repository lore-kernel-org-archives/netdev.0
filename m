From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [2/4] [IPSEC] Kill spurious hard expire messages
Date: Sun, 10 Apr 2005 05:29:26 +1000
Message-ID: <20050409192926.GA9423@gondor.apana.org.au>
References: <1112702604.1089.119.camel@jzny.localdomain> <20050409105452.GA7171@gondor.apana.org.au> <20050409111244.GB7171@gondor.apana.org.au> <1113049844.1090.23.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
        Masahide NAKAMURA <nakam@linux-ipv6.org>,
        Patrick McHardy <kaber@trash.net>, netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1113049844.1090.23.camel@jzny.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi Jamal:

On Sat, Apr 09, 2005 at 08:30:44AM -0400, jamal wrote:
> 
> This is nice since it seems to go on top of the patch i posted.
> I didnt get an ACK from Dave - so i assumed that patch is not on his 
> tree yet. Which tree are you using?

The Linus tree plus your patch.

> On Sat, 2005-04-09 at 07:12, Herbert Xu wrote:
> 
> > ===== net/xfrm/xfrm_policy.c 1.75 vs edited =====
> > --- 1.75/net/xfrm/xfrm_policy.c 2005-04-01 16:24:20 +10:00
> > +++ edited/net/xfrm/xfrm_policy.c       2005-04-09 18:02:53 +10:00
> > @@ -216,8 +216,8 @@
> > 
> > expired:
> >        read_unlock(&xp->lock);
> > -       km_policy_expired(xp, dir, 1);
> > -       xfrm_policy_delete(xp, dir);
> > +       if (!xfrm_policy_delete(xp, dir))
> > +               km_policy_expired(xp, dir, 1);
> >        xfrm_pol_put(xp);>
> > }
> >
> 
> If the policy was already dead you will still return a 0 from
> xfrm_policy_delete(). Fixable by policy_kill returning an int.

You're right.  The other callers of xfrm_policy_kill needs to
check it too.

I'll fix this up.

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
