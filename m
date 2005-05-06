From: jamal <hadi@cyberus.ca>
Subject: Re: resend patch:  xfrm policybyid
Date: Fri, 06 May 2005 07:53:00 -0400
Message-ID: <1115380381.7660.123.camel@localhost.localdomain>
References: <1115298877.7680.75.camel@localhost.localdomain>
	 <20050505213239.GA29526@gondor.apana.org.au>
	 <1115331436.8006.112.camel@localhost.localdomain>
	 <20050505231210.GA30574@gondor.apana.org.au>
	 <1115342122.7660.25.camel@localhost.localdomain>
	 <20050506013125.GA31780@gondor.apana.org.au>
	 <1115345403.7660.49.camel@localhost.localdomain>
	 <20050506085404.GA26719@gondor.apana.org.au>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20050506085404.GA26719@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 2005-06-05 at 18:54 +1000, Herbert Xu wrote:
> On Thu, May 05, 2005 at 10:10:03PM -0400, jamal wrote:
> > 
> > > The way I'm seeing it is that the index is simply a read-only value
> > > that's only provided by the kernel to the user as an aid in locating
> > > policies.
> > 
> > IOW, they are search keys. 
> 
> I'm afraid I still disagree.  

You are a reasonable man, so i am hoping you will end agreeing 
or agreeing to disagree;->

> There should only be one key that the
> user gets to set when adding policies that is guaranteed to be unique.
> As it is it's the selector.
> 

Note: The index was already guaranteed to be unique even without my
patch.

Just to make sure we are not speaking past each other:
A key is a column in a table that can be uniquely used to identify said
row. 
A table can have more than one key (a lot of relational databases do),
although it adds a lot of gunk in the kernel.
In this case actually the justification exists: The selector is needed
for data/packet path lookup key. The index for manager side
manageability. 

> Letting the user specify two independent keys which need to be unique
> is what is making your patch ugly and what IMHO will make the code
> unmaintainable.
> 

I did not add the code for index, Herbert ;->
whoever did missed some basic details - I am rectifying that. 
It will be much easir to get rid of the index as a key - at which point
it has no real value  or fix it. You cant have it both ways.

In my opinion the only key that should be used by the manager is the
index. User space should be able to map the selector to an index 
- same with the SAD. Its a lot more manageable that way. But again thats
a separate discussion (amongst a few other issues i have distate for in
the SPD/SAD). This actually is the simple one ;->

> Here is an analogy.  Think of the policies as files and the indicies
> as file descriptors.  The index is only valid while the policy is in
> the policy list (the file descriptor is only valid while the file is
> open).  When you add the policy, you don't get to specify what the
> index is (when you open a file, you don't get to specify what the
> file descriptor is).  

Of course you can specify the index at creation time! it does make sense
to. It's user space that manages these tables - much easier to specify
an index that makes sense to the manager so it can manage its
side of things easier. 
Otherwise all the MIBS and PIBS and policy management code that exists
and uses the concept of row indices in the world is wrong.

> Once the policy has been added, you will be
> given an index that you can use to read/delete the policy (once the
> file has been opened, you will be given a file descriptor that you
> can use to access/close the file).
> 

Good example that serves to make my point actually.
Indeed you can look at the fd as a key that the kernel uses.
The manager of the table is the kernel. The kernel dictates what the
fd could be (with some exceptions) because it is easier that way to
manage the addition, lookup and removal of these files.
 
The SPD, OTOH, is a table of policies managed by some entity in user
space like a KM (and not in the kernel). 
Standard approaches have long ago (probably before you and i were born)
to use indices to manage tables.  Look at SNMP, COPS, etc. There are
some exceptions to this, but this is in cases where they cant be
avoided.

> However, I must say that I still have absolutely no idea why anyone
> would need to set the index to arbitrary values.
> 

But you do know why someone would want to search or delete by it,
right?;->

cheers,
jamal
