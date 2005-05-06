From: jamal <hadi@cyberus.ca>
Subject: Re: resend patch:  xfrm policybyid
Date: Thu, 05 May 2005 22:10:03 -0400
Message-ID: <1115345403.7660.49.camel@localhost.localdomain>
References: <1115298877.7680.75.camel@localhost.localdomain>
	 <20050505213239.GA29526@gondor.apana.org.au>
	 <1115331436.8006.112.camel@localhost.localdomain>
	 <20050505231210.GA30574@gondor.apana.org.au>
	 <1115342122.7660.25.camel@localhost.localdomain>
	 <20050506013125.GA31780@gondor.apana.org.au>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20050506013125.GA31780@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 2005-06-05 at 11:31 +1000, Herbert Xu wrote:
> On Thu, May 05, 2005 at 09:15:22PM -0400, jamal wrote:
> > 
> > Thats a moot point really Herbert. I can think of a few apps that can
> > use this, but it shouldnt matter: The main point is correctness.
> 
> Ah, that's why we're talking past each other :) You're looking at
> it as a bug where we aren't setting the index when it is provided
> by the user.

It is a bug based on what common usage of what indices are used for in
tables. They are search keys.

> The way I'm seeing it is that the index is simply a read-only value
> that's only provided by the kernel to the user as an aid in locating
> policies.
> 

IOW, they are search keys. 
Search keys are unique and read-write. You cant just invent you rules
Herbert ;->
The typical rules are simple for indices:
a) you specify the index - if it doesnt conflict, it is accepted. You
can then use that key to search in the future
b) you dont specifiy the index, the kernel specifies one for you which
doesnt conflict.

We do b) only and override a). 

Look at these as array subscripts if you want an analogy. You can
reference an empty array slot but not one thats being used. If you dont
specify the array index then the kernel will provide one for you.

> In this respect it's just like xfrm_policy->curlft, it can be read
> by the user by it's only ever written by the kernel.  So whatever
> value the user provides us when adding/updating a policy is simply
> ignored.
> 

Theres a difference;-> you cant search by curlft i.e its not a key.

> Another way to look at it is that it's a handle that we're returning
> to the user so that they can talk about policies in an unambiguous way.
> 
> Does this make sense?
> 

You are emphasizing the uniqueuness feature of a search key ;->

> > You know what else you can do is get rid of the index totaly - that
> > would be fine with me. What do you say to that?
> 
> That would break user API/ABI so no :)

Understood.
There are a lot of things i think need fixing in both the SPD and SAD
that i am not touching - this is certainly one that i dont want to leave
alone. 

The other issues i will leave to another discussion  without distracting
this one;->

cheers,
jamal
