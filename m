From: jamal <hadi@cyberus.ca>
Subject: Re: resend patch:  xfrm policybyid
Date: Sat, 07 May 2005 08:38:16 -0400
Message-ID: <1115469496.19561.41.camel@localhost.localdomain>
References: <1115298877.7680.75.camel@localhost.localdomain>
	 <20050505213239.GA29526@gondor.apana.org.au>
	 <1115331436.8006.112.camel@localhost.localdomain>
	 <20050505231210.GA30574@gondor.apana.org.au>
	 <1115342122.7660.25.camel@localhost.localdomain>
	 <20050506013125.GA31780@gondor.apana.org.au>
	 <1115345403.7660.49.camel@localhost.localdomain>
	 <20050506085404.GA26719@gondor.apana.org.au>
	 <1115380381.7660.123.camel@localhost.localdomain>
	 <20050507105500.GA20283@gondor.apana.org.au>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20050507105500.GA20283@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 2005-07-05 at 20:55 +1000, Herbert Xu wrote:
> On Fri, May 06, 2005 at 07:53:00AM -0400, jamal wrote:
> > 
> > You are a reasonable man, so i am hoping you will end agreeing 
> > or agreeing to disagree;->
> 
> If it weren't for the fact that the only way of achieving what you
> want here is through ugly code then I wouldn't have any problems with
> it at all.
>  

Rewrite it Herbert ;-> I have no qualms as long as the feature is
available. I even promised not to harass you ;->


> > Note: The index was already guaranteed to be unique even without my
> > patch.
> 
> The difference is that the uniqueness is easy when we (the kernel) are
> the only ones setting it.  Once you let the user choose the value for
> index, that's where the horror starts.
> 

But the uniqueness is still maintained. Nothing changes there.

>  this case actually the justification exists: The selector is needed
> > for data/packet path lookup key. The index for manager side
> > manageability. 
> 
> I have no argument with the existence of the index per se.  What I am
> yet to be convinced of is the need for the user to set its value.

As i said in the last email, a lot of known management apps out there
typically deal with row indices when managing tables: examples include
SNMP, COPS, etc - and i am not sure how Racoon or pluto store their
policies but they would be a good fit as well. 
If you can specify what indices get used, then you can do some fast
lookups when need to (because you specify then based on how things are
laid out in your current tables). This is the way things are - i am not
trying to innovate anything here. 
How fast you add or delete these rules is a performance metric that
affects your setup/teardown rates.
 
Theres also another use of being able to use indices:  HA
synchronization in active/backup. If the manager wants to make sure the
active and backup are exactly the same and it(the manager) maintains
less amount of data it will ensure that both nodes have exactly the same
indices as well for the same policy.

Having said the above, the SAD as well oughta have an index; infact one
exists (the reqid) but is quiet bizzare. I dont wanna touch the SAD,
yet ;-> not for the next few months until we talk at netconf probably.
Actually this is a digression, so  just ignore i said it ;->

cheers,
jamal
