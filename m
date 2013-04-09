From: Paul Moore <pmoore@redhat.com>
Subject: Re: [PATCH] tcp: assign the sock correctly to an outgoing SYNACK packet
Date: Tue, 09 Apr 2013 11:57:49 -0400
Message-ID: <1874420.dSqDS2QrBc@sifl>
References: <3505145.vfXt1x4t0P@sifl> <5235720.yJLYRg7eit@sifl> <1365521576.3887.147.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Casey Schaufler <casey@schaufler-ca.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	mvadkert@redhat.com, selinux@tycho.nsa.gov,
	linux-security-module@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <1365521576.3887.147.camel@edumazet-glaptop>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tuesday, April 09, 2013 08:32:56 AM Eric Dumazet wrote:
> On Tue, 2013-04-09 at 11:17 -0400, Paul Moore wrote:
> > The "blob" is a void pointer, so 8 bytes.  We're talking about removing
> > the "secmark" field (4 bytes) and adding a void pointer (8 bytes).  I've
> > shown several different approaches that make this change without
> > increasing the overall size of the sk_buff struct.
> 
> You want to use 4 extra bytes in sk_buff. You'll have to show us why we
> close the way for other valid uses of the current holes.
> 
> I have no idea why its needed, and why it can't be solved in another
> way.

FWIW, I was focusing on arriving at a basic design that addressed the initial 
reasons for not including a security blob in a sk_buff.  In the beginning I 
thought it was both the need for LSM hook in the skb management routines as 
well as the memory overhead in the skb itself.  During the course of our 
discussion it became clear that the hooks were acceptable, it was the memory 
overhead that was the concern, so that is what I (and Casey) focused on.

Based on your latest comment, it appears that we have some possible candidates 
for adding a security blob (void *) to the sk_buff that address your technical 
arguments, I wasn't aware we had reached that point, but it is indeed good 
news.  Now we just need to make our case that it is the "Right Thing to Do", 
that is perfectly reasonable.

> It looks like _I_ have to do your work.

I don't believe I ever asked you to do anything other than to repost a patch 
you posted to the LSM list so we could get it included upstream.  A patch that 
you created to counter my proposed fix for a SELinux regression.  Further, I 
tested your patch, and ACK'd it earlier this morning.

I suppose I also asked you to explain/clarify a few of your technical 
objections a bit further so I could address them, but that just seems like 
normal peer design review.

> Sorry, I have no more time to spend on this topic. You'll have to convince
> David, not me.

Well, thank you for your time; I'm sure we'll get to talk about this again in 
the future.  It looks like we've had enough of a conversation now that I can 
start working on some patches.

-- 
paul moore
security and virtualization @ redhat

