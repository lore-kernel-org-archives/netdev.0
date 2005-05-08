From: jamal <hadi@cyberus.ca>
Subject: Re: [7/7] [IPSEC] Add XFRMA_SA/XFRMA_POLICY for delete notification
Date: Sun, 08 May 2005 09:56:33 -0400
Message-ID: <1115560594.19561.117.camel@localhost.localdomain>
References: <20050507071824.GA5753@gondor.apana.org.au>
	 <20050507071930.GC5753@gondor.apana.org.au>
	 <20050507072058.GD5753@gondor.apana.org.au>
	 <20050507072139.GE5753@gondor.apana.org.au>
	 <20050507072216.GF5753@gondor.apana.org.au>
	 <20050507072251.GG5753@gondor.apana.org.au>
	 <20050507072349.GH5753@gondor.apana.org.au>
	 <1115467457.19561.5.camel@localhost.localdomain>
	 <20050507122504.GA21693@gondor.apana.org.au>
	 <1115470004.19561.49.camel@localhost.localdomain>
	 <20050507193538.GA28991@gondor.apana.org.au>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
        Masahide NAKAMURA <nakam@linux-ipv6.org>,
        Patrick McHardy <kaber@trash.net>, netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20050507193538.GA28991@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, 2005-08-05 at 05:35 +1000, Herbert Xu wrote:
> On Sat, May 07, 2005 at 08:46:44AM -0400, jamal wrote:
> > 
> > No, this is not true. Study the tc code.
> > It is nice to be able to return exactly the same detail - user space can
> > then infer what exactly happened. It is nicer to be able to return more
> > detail because user space doesnt have to infer anything.
> 
> This patch is making it return more detail, not less! The full
> description of the deleted policy/state is still being returned,
> albeit as RTA payloads.

It's the other extreme of what i thought.
The only thing user space needs to know is what object was deleted.
If you just passed the id, it could be deduced if user space maintained
state; if you pass the object, no such deduction is needed.

> Prior to the change, netlink users do not know whether the original
> policy delete request was by selector or by id.  Now that information
> is also returned.
> 

Why would someone need to deduce whether it has been deleted by index or
selector?
If you gave me the object - i can reproduce the action of deleting it.
Thats the _only_ important_ thing.

> > You describe the patch this way
> > 
> > ---
> > This patch changes the format of the XFRM_MSG_DELSA and
> > XFRM_MSG_DELPOLICY notification so that the main message
> > sent is of the same format as that received by the kernel
> > if the original message was via netlink.
> > ----
> > 
> > That it only happens when you delete via netlink. Is this not so?
> 
> The same change applies even if you sent the delete via pfkey.  What
> the change does is to make netlink always send a delete message that
> is valid in the sense that if you sent it back to netlink then it
> would delete that policy/state.
> 

Does pfkey have ability to delete by index and selector?
If yes, how do you distinguish the two cases when you are sending the
netlink event?

> As it is the netlink delete messages sent by notification are invalid
> by its own standard.
> 

It doesnt seem to me what you provided in the patch produces exactly the
same thing that was sent by user space back in the event.
You introduce some other new TLVs to reflect it back.
But even that is besides the point:
None of those xfrm objects obey any of the standard rules 
netlink uses to begin with - you have more than one way of deleting an
object. What you need to do is the detail of what object was deleted.

Heres what i will say so we can put this to rest:
The patch is unneeded (i hate to use strong words like bogus - but it is
getting close to that), but if you feel strongly about it just lets have
it well documented and provide the iproute2 patch as well.

cheers,
jamal
