From: jamal <hadi@cyberus.ca>
Subject: Re: [PKT_SCHED]: Allow using nfmark as key in U32 classifier.
Date: 29 Dec 2004 09:20:54 -0500
Message-ID: <1104330054.1089.329.camel@jzny.localdomain>
References: <20041228161117.GD32419@postel.suug.ch>
	 <1104251817.1090.164.camel@jzny.localdomain>
	 <20041228192603.GE32419@postel.suug.ch>
	 <1104268498.1090.254.camel@jzny.localdomain>
	 <20041228221021.GF32419@postel.suug.ch>
	 <1104275197.1100.276.camel@jzny.localdomain>
	 <20041228231916.GG32419@postel.suug.ch>
	 <1104277165.1100.291.camel@jzny.localdomain>
	 <20041229000928.GH32419@postel.suug.ch>
	 <1104282811.1090.314.camel@jzny.localdomain>
	 <20041229124842.GI32419@postel.suug.ch>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com,
        Patrick McHardy <kaber@trash.net>
Return-path: <netdev-bounce@oss.sgi.com>
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20041229124842.GI32419@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 2004-12-29 at 07:48, Thomas Graf wrote:
> * jamal <1104282811.1090.314.camel@jzny.localdomain> 2004-12-28 20:13
..
> The ematch TLV contains an array of ematches, every
> ematch contains the logic relation to the next (2 bits) and a flag to
> invert the meaning (1 bit). A special ematch containing an index exists
> to implement precdence.
> 
> A AND (B1 OR B2) AND C AND D
> 
> 
>               ------->-PUSH-------
>     -->--    /         -->--      \   -->--
>    /     \  /         /     \      \ /     \
> +-------+-------+-------+-------+-------+--------+
> | A AND | B AND | C AND | D END | B1 OR | B2 END |
> +-------+-------+-------+-------+-------+--------+
>                     \                      /
>                      --------<-POP---------
> 
> A simple check that a jump index is never smaller than the current
> index (excluding backward jumps via stack) catches endless loop
> and avoids the use of a ttl.
> 

Sounds good.
Given the opportunity: I think we need to put those flags as well for
the u32 keys(and other classifiers) so we can have similar logic?
Also in the case of u32 (to take this opportunity) i would like to stash
state inot a 16 bit ID to help in pretty printing the matches.
So if we have an extra 32 bits for flags:ID probably 8 bits for your
need for flags, 16 bits for private Id and maybe another 8 bit for
something else like versioning...
Thoughts?


> > Recall, the opportunity to do more in terms of logical expressions within u32 
> > exists because we can introduce more interesting keys ...
> 
> We could reuse the 8 unused bits after nkeys in tc_u32sel too. iproute2 sets
> them to 0 so we can simply use them without anyone noticing.

I would recommend just introducing the extra 32 bits per key. So much
easier.

> > I dont know where you and Patrick are with the code but it think it
> > would be safe for me to work off 2610-bk1. Tommorow i am working on some
> > e1000 stuff - but day after i should be able to touch the action code. 
> 
> I'm not touching the action bits but Patrick is as far as I know.

Ok, dont wanna conflict with work hes doing - so i will wait until
tommorow to see what hes upto. CCed him.

cheers,
jamal
