From: jamal <hadi@cyberus.ca>
Subject: Re: [PKT_SCHED]: Allow using nfmark as key in U32 classifier.
Date: 28 Dec 2004 18:39:25 -0500
Message-ID: <1104277165.1100.291.camel@jzny.localdomain>
References: <20041227121658.GI7884@postel.suug.ch>
	 <1104240053.1100.53.camel@jzny.localdomain>
	 <20041228134022.GA32419@postel.suug.ch>
	 <1104242397.1090.94.camel@jzny.localdomain>
	 <20041228161117.GD32419@postel.suug.ch>
	 <1104251817.1090.164.camel@jzny.localdomain>
	 <20041228192603.GE32419@postel.suug.ch>
	 <1104268498.1090.254.camel@jzny.localdomain>
	 <20041228221021.GF32419@postel.suug.ch>
	 <1104275197.1100.276.camel@jzny.localdomain>
	 <20041228231916.GG32419@postel.suug.ch>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20041228231916.GG32419@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 2004-12-28 at 18:19, Thomas Graf wrote:
> * jamal <1104275197.1100.276.camel@jzny.localdomain> 2004-12-28 18:06
> > Its maintainance work. Nothing it provides isnt provided by
> > new policer. 
> 
> I'll remove it.
> 

Well one of your goals was to reduce the ifdef  cluter.
That goal is achieved with that goal. So I would keep it as is for now
but kill it in the future. I am hoping we are talking about the same
thing here - the old policer ;->


> > Since these keys are packed in a selector and the selector is what gets
> > transported from/to user space we need a selector2 which packs these new
> > keys instead. Makes sense? i.e need a TCA_U32_SEL2 where the extended
> > matches are stored. 
> 
> Why? I don't get that. Generic matches must only be considered if all
> keys of u32 match. u32 keys are just ANDed matches if one fails we can
> directly declare the classifier as unmatched. 

yes - and that still applies here but you can now interleaf - as i
mentioned earlier:

match u32 ..
ematch string "Thomas" ...
match u32 ...
ematch meta tcindex ..

I dont wanna go into details of whether we could actually make the new
keys do more than just strict AND from left to right - but you can see
the potential to "fix" this if we are defining a new key ;->

The same applies for interleafing of actions and eactions.

> The only thing we would
> gain is that we could add multiple generic matches but with lack of real
> logical expressions. I'd rather implemnt some simple form of logical
> expression in the generic part so all classifiers can benfit.

Ok, the logical expressions are the tricky part. But refer to what i am
saying above. You still need to be backward compatible. But for the new
keys you could go onto the adventorous side. I havent given the logical
expressions much thought but i will in the background

> > Makes sense?
> 
> Not for me. ;->
> 
> > Back to what i said earlier i can now write a single page of code
> > to scan for word "Thomas" if i get a match on TCP port 25 for all IP
> > addresses... i.e metadata is a subset of all this.
> 
> Agreed, and smart as you are you simply take the Knuth-Morris-Pratt
> code out of my EGP patch to get some performance. ;->

Of course;->  Ive worked long enough in Linux to appreciate 
the definition of TheLinuxWay(tm) ;-> I also get to inherit your bugs
this way.

cheers,
jamal
