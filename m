From: jamal <hadi@cyberus.ca>
Subject: Re: [7/7] [IPSEC] Add XFRMA_SA/XFRMA_POLICY for delete notification
Date: Sun, 08 May 2005 20:06:39 -0400
Message-ID: <1115597200.19561.215.camel@localhost.localdomain>
References: <20050507072058.GD5753@gondor.apana.org.au>
	 <20050507072139.GE5753@gondor.apana.org.au>
	 <20050507072216.GF5753@gondor.apana.org.au>
	 <20050507072251.GG5753@gondor.apana.org.au>
	 <20050507072349.GH5753@gondor.apana.org.au>
	 <1115467457.19561.5.camel@localhost.localdomain>
	 <20050507122504.GA21693@gondor.apana.org.au>
	 <1115470004.19561.49.camel@localhost.localdomain>
	 <20050507193538.GA28991@gondor.apana.org.au>
	 <1115560594.19561.117.camel@localhost.localdomain>
	 <20050508214049.GA14415@gondor.apana.org.au>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
        Masahide NAKAMURA <nakam@linux-ipv6.org>,
        Patrick McHardy <kaber@trash.net>, netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20050508214049.GA14415@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 2005-09-05 at 07:40 +1000, Herbert Xu wrote:
> On Sun, May 08, 2005 at 09:56:33AM -0400, jamal wrote:
> > 
> > Why would someone need to deduce whether it has been deleted by index or
> > selector?
> 
> It isn't just about deducing the message.  It's about sending a delete
> message in the same format as we would receive them.  As it is the
> delete message sent would be not be accepted if you sent it back to the
> 

If you enumerate all netlink messages, you will see this is not always
the case. It is a nice but not a necessary condition; infact, not even
what you generate with that patch is _the same_ message that was sent
(you add new TLVs in the response that didnt exist in user->kernel).

What is necessary is that if i look at the event i know exactly what was
deleted. If i have such detail, i can build the message that was sent
from user->kernel to delete the object (because i know exactly what was
deleted). 
As an example:
I can derive the xfrm_usersa_id that was sent to the kernel if the event
sent me xfrm_usersa_info and therefore build the same a message that
will delete _exactly_ the same object. 

It does get worse on occasion (I can point at tc filters) - where you
really cant derive the deleted object.


> > If yes, how do you distinguish the two cases when you are sending the
> > netlink event?
> 
> Using the byid attribute that *you* introduced :)
> 

Ok, theres no inconsistency then.

> > It doesnt seem to me what you provided in the patch produces exactly the
> > same thing that was sent by user space back in the event.
> 
> That's not the point.  The point is if you send exactly the same
> message to the kernel, even with the RTAs attached, the kernel
> would accept it and perform the deletion if there is a matching
> policy.

So you are depending on the kernel not checking for the extra TLVs you
send?;->
Refer to what i said above.

>  
> > Heres what i will say so we can put this to rest:
> > The patch is unneeded (i hate to use strong words like bogus - but it is
> > getting close to that), but if you feel strongly about it just lets have
> > it well documented and provide the iproute2 patch as well.
> 
> I'll leave the decision up to Dave.

Like i said: I think its extraneous stuff that is unneeded(what is in
there at the moment is sufficient detail) - but because theres no
inconsistency, i will not squirm in pain if it is included. I am
agreeing to disagree essentially ;->

cheers,
jamal
