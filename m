From: jamal <hadi@cyberus.ca>
Subject: Re: [PKT_SCHED]: Allow using nfmark as key in U32 classifier.
Date: 03 Jan 2005 09:39:16 -0500
Message-ID: <1104763156.1048.531.camel@jzny.localdomain>
References: <20041230174313.GB32419@postel.suug.ch>
	 <1104469111.1049.219.camel@jzny.localdomain>
	 <20041231110836.GD32419@postel.suug.ch>
	 <1104505142.1048.262.camel@jzny.localdomain>
	 <20041231153930.GN32419@postel.suug.ch>
	 <1104511494.1048.303.camel@jzny.localdomain>
	 <20041231181153.GP32419@postel.suug.ch>
	 <1104526311.1047.379.camel@jzny.localdomain>
	 <20050101183230.GT32419@postel.suug.ch>
	 <1104622934.1047.460.camel@jzny.localdomain>
	 <20050102001338.GV32419@postel.suug.ch>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20050102001338.GV32419@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 2005-01-01 at 19:13, Thomas Graf wrote:
> * jamal <1104622934.1047.460.camel@jzny.localdomain> 2005-01-01 18:42
> > what happened to the good old SEL TLV (which i believe we called SEL2
> > now); or maybe thats what contains this TLV?
> 
> Please look at the patch I posted in the other post. I think
> we missudnerstand each other.

Will do.

> > Why do you need to specify "nmatches".
> 
> It's mainly a shortcut to validate precedence jumps so I
> can avoid traversing the RTA chain twice. It could be
> avoided but is quite handy to speed things up and
> also acts for validation purposes to check consistency of
> the match list.

Ok. 

> > What is TCA_EMATCH_TREE_LIST for? Looks like another TLV nesting. Not
> > needed, you just plumb the T=1,..T=N right after the header.
> 
> No, what if we need some more stuff in the selector TLV? We can't
> modify the header TLV w/o breaking backwards compatibility. Adding
> this addtional nesting allows to simply add stuff after TREE_LIST
> TLV.

Good point.

> > I think the way you have it is fine - and believe it is the way the
> > action code has it for the list.
> 
> You're using a maximum prio aren't you? I use a RTA_OK() loop
> supporting unlimited number of matches without the need to
> allocate rtattr pointer array.

Sounds reasonable;  
Note in my case, you probably want a limit on how many actions you chain
in one policy - I would suggest you do the same as well. In other words
even if you do it that way, have a limit check/setting somewhere.

cheers,
jamal
