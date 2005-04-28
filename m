From: jamal <hadi@cyberus.ca>
Subject: Re: patch: policy update by id
Date: Wed, 27 Apr 2005 21:13:36 -0400
Message-ID: <1114650816.7663.13.camel@localhost.localdomain>
References: <1114602874.7670.4.camel@localhost.localdomain>
	 <1114604657.7670.22.camel@localhost.localdomain>
	 <1114604826.7670.24.camel@localhost.localdomain>
	 <20050427233924.GA22238@gondor.apana.org.au>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20050427233924.GA22238@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 2005-28-04 at 09:39 +1000, Herbert Xu wrote:
> On Wed, Apr 27, 2005 at 08:27:06AM -0400, Jamal Hadi Salim wrote:
> >
> > --- /usr/src/26117-mod/net/xfrm/xfrm_policy.c	2005/04/27 11:32:13	1.1
> > +++ /usr/src/26117-mod/net/xfrm/xfrm_policy.c	2005/04/27 12:25:24
> > @@ -345,7 +345,9 @@
> >  
> >  	write_lock_bh(&xfrm_policy_lock);
> >  	for (p = &xfrm_policy_list[dir]; (pol=*p)!=NULL;) {
> > -		if (!delpol && memcmp(&policy->selector, &pol->selector, sizeof(pol->selector)) == 0) {
> > +		if (!delpol && 
> > +		((!excl && policy->index && (policy->index == pol->index)) || 
> > +		 (memcmp(&policy->selector, &pol->selector, sizeof(pol->selector)) == 0))) {
> 
> I have no problems with the idea itself.  However, I have a couple of
> minor issues with this patch :)
> 
> First of all please align the continued lines to the if expression, e.g.,
> 		if (!delpol && 
> 		    (policy->index && (policy->index == pol->index)) || 
> 

np. sorry, i was rushing out - testing as we speak.

> Also the excl check doesn't make sense.  You should let the
> following excl check take place after you've found out that
> the indices is identical.
> 

the policy->index is only relevant for the update not the add;
the update could also be done by selector. So i didnt follow.

cheers,
jamal 
