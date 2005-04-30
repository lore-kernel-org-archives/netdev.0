From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: patch2: del/get byid
Date: Sat, 30 Apr 2005 10:12:48 +1000
Message-ID: <20050430001248.GA22927@gondor.apana.org.au>
References: <20050428024253.GA23695@gondor.apana.org.au> <1114656932.7663.88.camel@localhost.localdomain> <20050428030325.GB23823@gondor.apana.org.au> <1114658657.7663.110.camel@localhost.localdomain> <1114698033.7663.197.camel@localhost.localdomain> <20050428231154.GA14215@gondor.apana.org.au> <1114779104.7800.22.camel@localhost.localdomain> <1114816846.8929.6.camel@localhost.localdomain> <20050429234952.GB22699@gondor.apana.org.au> <1114819281.8929.9.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>, netdev@oss.sgi.com,
        "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1114819281.8929.9.camel@localhost.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, Apr 29, 2005 at 08:01:21PM -0400, jamal wrote:
> On Sat, 2005-30-04 at 09:49 +1000, Herbert Xu wrote:
> > On Fri, Apr 29, 2005 at 07:20:46PM -0400, jamal wrote:
> > 
> > >  	write_unlock_bh(&xfrm_policy_lock);
> > >  
> > > -	if (delpol) {
> > > -		xfrm_policy_kill(delpol);
> > > +	if (delp) {
> > > +		xfrm_policy_kill(delp);
> > >  	}
> > 
> > This is racy.  The policy could be killed by the timer in the middle.
> 
> the policy_kill is?

1) You find delpol using xfrm_policy_byid/xfrm_policy_bysel.
2) The timer kicks in and unlinks delpol from the list.
3) You take the list lock and continue to use delpol as if it was
   still on the list.
4) You call xfrm_policy_kill on delpol again even though it's already
   dead.
 
> > This is also getting pretty hairy for something that nobody has needed so
> > far.  Which user-space application is going to use this index thing?
> 
> did you see the attachment i put with ip x tests?

Well I meant a usage other than a test suite :)
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
