From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PKT_SCHED]: Allow using nfmark as key in U32 classifier.
Date: Wed, 29 Dec 2004 01:09:28 +0100
Message-ID: <20041229000928.GH32419@postel.suug.ch>
References: <20041228134022.GA32419@postel.suug.ch> <1104242397.1090.94.camel@jzny.localdomain> <20041228161117.GD32419@postel.suug.ch> <1104251817.1090.164.camel@jzny.localdomain> <20041228192603.GE32419@postel.suug.ch> <1104268498.1090.254.camel@jzny.localdomain> <20041228221021.GF32419@postel.suug.ch> <1104275197.1100.276.camel@jzny.localdomain> <20041228231916.GG32419@postel.suug.ch> <1104277165.1100.291.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1104277165.1100.291.camel@jzny.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* jamal <1104277165.1100.291.camel@jzny.localdomain> 2004-12-28 18:39
> On Tue, 2004-12-28 at 18:19, Thomas Graf wrote:
> > Why? I don't get that. Generic matches must only be considered if all
> > keys of u32 match. u32 keys are just ANDed matches if one fails we can
> > directly declare the classifier as unmatched. 
> 
> yes - and that still applies here but you can now interleaf - as i
> mentioned earlier:
> 
> match u32 ..
> ematch string "Thomas" ...
> match u32 ...
> ematch meta tcindex ..

Yes but the only avantage of this is that a u32 match can be
made dependant on a ematch. Is this really worth special
handling? It requires special handling not needed for any
of the other classifiers.

I understand your point but don't agree at the moment. I
might change my mind tomorrow ;->

> I dont wanna go into details of whether we could actually make the new
> keys do more than just strict AND from left to right - but you can see
> the potential to "fix" this if we are defining a new key ;->

We should rather do it on cls_api level, unfortunantely it's not that
simple but the current status of having one classifier kind per prio and
no way to interconnect them must be changed somewhen. 

> Ok, the logical expressions are the tricky part. But refer to what i am
> saying above. You still need to be backward compatible. But for the new
> keys you could go onto the adventorous side. I havent given the logical
> expressions much thought but i will in the background

Implementing logical expressions directly into u32 would be bad but
we could have u32 hold a expression tree rather than the ematch
directly which means you could do

match u32 ..
(ematch meta nfmark .. or string "...")
match u32 ..
