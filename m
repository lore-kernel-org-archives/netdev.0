From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PKT_SCHED]: Allow using nfmark as key in U32 classifier.
Date: Wed, 29 Dec 2004 00:19:16 +0100
Message-ID: <20041228231916.GG32419@postel.suug.ch>
References: <20041227121658.GI7884@postel.suug.ch> <1104240053.1100.53.camel@jzny.localdomain> <20041228134022.GA32419@postel.suug.ch> <1104242397.1090.94.camel@jzny.localdomain> <20041228161117.GD32419@postel.suug.ch> <1104251817.1090.164.camel@jzny.localdomain> <20041228192603.GE32419@postel.suug.ch> <1104268498.1090.254.camel@jzny.localdomain> <20041228221021.GF32419@postel.suug.ch> <1104275197.1100.276.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1104275197.1100.276.camel@jzny.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* jamal <1104275197.1100.276.camel@jzny.localdomain> 2004-12-28 18:06
> Its maintainance work. Nothing it provides isnt provided by
> new policer. 

I'll remove it.

> It is not proper spot for the matches and infact
> should go in as a separate patch altogether (relation is very minimal).
> 
> For the matches, the checks are going to be per key _not_ at the
> selector level; i.e:
> 
> struct tc_newu32_key
> {
>         __u32           mask;
>         __u32           val;
>         int             off;
>         int             offmask;
> 	pointer to extendedmatches here.
> };
> 
> Since these keys are packed in a selector and the selector is what gets
> transported from/to user space we need a selector2 which packs these new
> keys instead. Makes sense? i.e need a TCA_U32_SEL2 where the extended
> matches are stored. 

Why? I don't get that. Generic matches must only be considered if all
keys of u32 match. u32 keys are just ANDed matches if one fails we can
directly declare the classifier as unmatched. The only thing we would
gain is that we could add multiple generic matches but with lack of real
logical expressions. I'd rather implemnt some simple form of logical
expression in the generic part so all classifiers can benfit.

> Makes sense?

Not for me. ;->

> Back to what i said earlier i can now write a single page of code
> to scan for word "Thomas" if i get a match on TCP port 25 for all IP
> addresses... i.e metadata is a subset of all this.

Agreed, and smart as you are you simply take the Knuth-Morris-Pratt
code out of my EGP patch to get some performance. ;->
