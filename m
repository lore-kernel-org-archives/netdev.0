From: jamal <hadi@cyberus.ca>
Subject: Re: [PKT_SCHED]: Allow using nfmark as key in U32 classifier.
Date: 01 Jan 2005 18:42:14 -0500
Message-ID: <1104622934.1047.460.camel@jzny.localdomain>
References: <20041229150140.GJ32419@postel.suug.ch>
	 <1104335620.1025.22.camel@jzny.localdomain>
	 <20041230174313.GB32419@postel.suug.ch>
	 <1104469111.1049.219.camel@jzny.localdomain>
	 <20041231110836.GD32419@postel.suug.ch>
	 <1104505142.1048.262.camel@jzny.localdomain>
	 <20041231153930.GN32419@postel.suug.ch>
	 <1104511494.1048.303.camel@jzny.localdomain>
	 <20041231181153.GP32419@postel.suug.ch>
	 <1104526311.1047.379.camel@jzny.localdomain>
	 <20050101183230.GT32419@postel.suug.ch>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20050101183230.GT32419@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 2005-01-01 at 13:32, Thomas Graf wrote:

> OK, I changed my mind while implementing it and a selector now looks
> like this:
> 
> Selector TLV:
> 
>  +----------------------------+
>  | TCA_EMATCH_TREE_HDR        |
>  +----------------------------+
>  | TCA_EMATCH_TREE_LIST       |
>  | +------------------------+ |
>  | | T=1 Match 1            | |
>  | +------------------------+ |
>  | | T=2 Match 2            | |
>  | +------------------------+ |
>  | | T=N Match N            | |
>  | +------------------------+ |
>  +----------------------------+
> 

what happened to the good old SEL TLV (which i believe we called SEL2
now); or maybe thats what contains this TLV?

> So we can put more into the selector if needed without breaking
> compatibility. TCA_EMATCH_TREE_HDR currently contains `nmatches'
> specifying N and progid holding the PID you talked about.

Ok, so i think you may be saying the old selector stays intact then
(sans the matches)?
Why do you need to specify "nmatches".
You know exactly where each one starts and ends (from the TLVs).

What is TCA_EMATCH_TREE_LIST for? Looks like another TLV nesting. Not
needed, you just plumb the T=1,..T=N right after the header.

> The match TLVs must have a continous numbering because I don't
> want to define limits as done in the action code.

I think the way you have it is fine - and believe it is the way the
action code has it for the list.

> I'll post an RFC patch tomorrow implementing the API and a
> simple ematch.

Nice. I have started implementing the eaction code but too obsessed with
this other thing i am working on - hopefully i will get to it before my
vacation expires.

cheers,
jamal
