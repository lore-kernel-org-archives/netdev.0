From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PKT_SCHED]: Allow using nfmark as key in U32 classifier.
Date: Sun, 2 Jan 2005 01:13:38 +0100
Message-ID: <20050102001338.GV32419@postel.suug.ch>
References: <20041230174313.GB32419@postel.suug.ch> <1104469111.1049.219.camel@jzny.localdomain> <20041231110836.GD32419@postel.suug.ch> <1104505142.1048.262.camel@jzny.localdomain> <20041231153930.GN32419@postel.suug.ch> <1104511494.1048.303.camel@jzny.localdomain> <20041231181153.GP32419@postel.suug.ch> <1104526311.1047.379.camel@jzny.localdomain> <20050101183230.GT32419@postel.suug.ch> <1104622934.1047.460.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1104622934.1047.460.camel@jzny.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* jamal <1104622934.1047.460.camel@jzny.localdomain> 2005-01-01 18:42
> what happened to the good old SEL TLV (which i believe we called SEL2
> now); or maybe thats what contains this TLV?

Please look at the patch I posted in the other post. I think
we missudnerstand each other.

> > So we can put more into the selector if needed without breaking
> > compatibility. TCA_EMATCH_TREE_HDR currently contains `nmatches'
> > specifying N and progid holding the PID you talked about.
> 
> Ok, so i think you may be saying the old selector stays intact then
> (sans the matches)?

Right, old selector TLV statys as-is. Although I have to look
u32 closely before I can make final statements.

> Why do you need to specify "nmatches".

It's mainly a shortcut to validate precedence jumps so I
can avoid traversing the RTA chain twice. It could be
avoided but is quite handy to speed things up and
also acts for validation purposes to check consistency of
the match list.

> What is TCA_EMATCH_TREE_LIST for? Looks like another TLV nesting. Not
> needed, you just plumb the T=1,..T=N right after the header.

No, what if we need some more stuff in the selector TLV? We can't
modify the header TLV w/o breaking backwards compatibility. Adding
this addtional nesting allows to simply add stuff after TREE_LIST
TLV.

> I think the way you have it is fine - and believe it is the way the
> action code has it for the list.

You're using a maximum prio aren't you? I use a RTA_OK() loop
supporting unlimited number of matches without the need to
allocate rtattr pointer array.
