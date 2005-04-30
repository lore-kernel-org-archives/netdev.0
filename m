From: jamal <hadi@cyberus.ca>
Subject: Re: patch2: del/get byid
Date: Fri, 29 Apr 2005 20:35:57 -0400
Message-ID: <1114821357.8929.27.camel@localhost.localdomain>
References: <20050428024253.GA23695@gondor.apana.org.au>
	 <1114656932.7663.88.camel@localhost.localdomain>
	 <20050428030325.GB23823@gondor.apana.org.au>
	 <1114658657.7663.110.camel@localhost.localdomain>
	 <1114698033.7663.197.camel@localhost.localdomain>
	 <20050428231154.GA14215@gondor.apana.org.au>
	 <1114779104.7800.22.camel@localhost.localdomain>
	 <1114816846.8929.6.camel@localhost.localdomain>
	 <20050429234952.GB22699@gondor.apana.org.au>
	 <1114819281.8929.9.camel@localhost.localdomain>
	 <20050430001248.GA22927@gondor.apana.org.au>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>, netdev@oss.sgi.com,
        "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20050430001248.GA22927@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 2005-30-04 at 10:12 +1000, Herbert Xu wrote:
> On Fri, Apr 29, 2005 at 08:01:21PM -0400, jamal wrote:

> > the policy_kill is?
> 
> 1) You find delpol using xfrm_policy_byid/xfrm_policy_bysel.

Which increments the refcnt

> 2) The timer kicks in and unlinks delpol from the list.

How does this happen again? One path i see is an expiry of delpol about
the same time. 

> 3) You take the list lock and continue to use delpol as if it was
>    still on the list.

I am assuming the refcount is sufficient to protect it.

> 4) You call xfrm_policy_kill on delpol again even though it's already
>    dead.

It can only be dead if ->dead is set and refcnt hits zero, no?

>  
> > > This is also getting pretty hairy for something that nobody has needed so
> > > far.  Which user-space application is going to use this index thing?
> > 
> > did you see the attachment i put with ip x tests?
> 
> Well I meant a usage other than a test suite :)

surely ip is a user space application. Correctness is also valuable
regardless of whether theres an app using it today or not.

cheers,
jamal
