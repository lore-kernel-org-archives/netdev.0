From: jamal <hadi@cyberus.ca>
Subject: Re: [2/4] [IPSEC] Kill spurious hard expire messages
Date: 11 Apr 2005 07:20:20 -0400
Message-ID: <1113218420.1090.351.camel@jzny.localdomain>
References: <1112702604.1089.119.camel@jzny.localdomain>
	 <20050409105452.GA7171@gondor.apana.org.au>
	 <20050409111244.GB7171@gondor.apana.org.au>
	 <1113049844.1090.23.camel@jzny.localdomain>
	 <20050409192926.GA9423@gondor.apana.org.au>
	 <20050409200306.GA9660@gondor.apana.org.au>
	 <1113142244.1088.287.camel@jzny.localdomain>
	 <20050410212707.GA30337@gondor.apana.org.au>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
        Masahide NAKAMURA <nakam@linux-ipv6.org>,
        Patrick McHardy <kaber@trash.net>, netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20050410212707.GA30337@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Herbert,

On Sun, 2005-04-10 at 17:27, Herbert Xu wrote:

> 
> What I am saying is that this is impossible.  If it really bothers you
> we can turn the WARN_ON into a BUG.
> 

We started this discussion by asserting that an expire may be issued on
a policy (or state) despite a delete event notification already having
happened. Thats what we were/are trying to stop, no?
What i am saying is you are not stopping that with this:
---
  if (!xfrm_policy_delete(xp, dir))
        km_policy_expired(xp, dir, 1);
---

xfrm_policy_delete will return 0 whether the policy is dead or not.
OTOH, if it returns <0 for the case where it is dead, then an expire
event will not be issued. 

cheers,
jamal
