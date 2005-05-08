From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: resend patch:  xfrm policybyid
Date: Sun, 8 May 2005 18:07:30 +1000
Message-ID: <20050508080730.GA30512@gondor.apana.org.au>
References: <20050505213239.GA29526@gondor.apana.org.au> <1115331436.8006.112.camel@localhost.localdomain> <20050505231210.GA30574@gondor.apana.org.au> <1115342122.7660.25.camel@localhost.localdomain> <20050506013125.GA31780@gondor.apana.org.au> <1115345403.7660.49.camel@localhost.localdomain> <20050506085404.GA26719@gondor.apana.org.au> <1115380381.7660.123.camel@localhost.localdomain> <20050507105500.GA20283@gondor.apana.org.au> <1115469496.19561.41.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1115469496.19561.41.camel@localhost.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, May 07, 2005 at 08:38:16AM -0400, jamal wrote:
> 
> Rewrite it Herbert ;-> I have no qualms as long as the feature is
> available. I even promised not to harass you ;->

Sorry, I can't think of any good ways to implement what you want.

> > The difference is that the uniqueness is easy when we (the kernel) are
> > the only ones setting it.  Once you let the user choose the value for
> > index, that's where the horror starts.
> 
> But the uniqueness is still maintained. Nothing changes there.

The difference is that we now have to guarantee the uniqueness of
two unrelated fields during insertion: the index as well as the
selector.  This is where the complexity of your patch comes from.

> As i said in the last email, a lot of known management apps out there
> typically deal with row indices when managing tables: examples include
> SNMP, COPS, etc - and i am not sure how Racoon or pluto store their
> policies but they would be a good fit as well. 
> If you can specify what indices get used, then you can do some fast
> lookups when need to (because you specify then based on how things are
> laid out in your current tables). This is the way things are - i am not
> trying to innovate anything here. 
> How fast you add or delete these rules is a performance metric that
> affects your setup/teardown rates.

I'm afraid I don't buy this.  The policies are not stored in a
linear random-access data structure.  So setting the index
doesn't help performance one tiny bit.

In future it'll probably become a hash table or a tree, in neither
case will there be a linear index that could be used to determine
insertion/deletion.

> Theres also another use of being able to use indices:  HA
> synchronization in active/backup. If the manager wants to make sure the
> active and backup are exactly the same and it(the manager) maintains
> less amount of data it will ensure that both nodes have exactly the same
> indices as well for the same policy.

Please elaborate by giving an example of how the index is actually
used.  Sorry, but as it is I'm too thick to see your point :)

> Having said the above, the SAD as well oughta have an index; infact one
> exists (the reqid) but is quiet bizzare. I dont wanna touch the SAD,
> yet ;-> not for the next few months until we talk at netconf probably.

The reqid is definitely not an index.  In fact it is not unique at all.
It's a way of condensing all the fields in a SA template into one u32.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
