From: jamal <hadi@cyberus.ca>
Subject: Re: [RFC] batched tc to improve change throughput
Date: 17 Jan 2005 17:49:57 -0500
Message-ID: <1106002197.1046.19.camel@jzny.localdomain>
References: <20050117152312.GC26856@postel.suug.ch>
	 <1105976711.1078.1.camel@jzny.localdomain>
	 <20050117160539.GD26856@postel.suug.ch>
	 <1105979807.1078.16.camel@jzny.localdomain>
	 <20050117165626.GE26856@postel.suug.ch>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>, Stephen Hemminger <shemminger@osdl.org>,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20050117165626.GE26856@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 2005-01-17 at 11:56, Thomas Graf wrote:
> * jamal <1105979807.1078.16.camel@jzny.localdomain> 2005-01-17 11:36
[..]
> > Didnt follow this - uses the same code as command line. What logic gets
> > duplicated?
> 
> The parsing of top level nodes.

Probably not very big deal - will just force you to type in
the commands in full over and over in your batch file

> > >  - it doesn't allow any commenting
> > 
> > Trivial thing you can fix in about 33.5 seconds ;-
> 
> Simple full-line comments yes, mid-line comments no. -batch
> is also not able to split things across multiple lines.
> 
> I want my scripts to look like this:
> 
> /**
>  * filter dla_fp
>  * match DLA traffic at lower watermark
>  */
> tc filter add
> 	dev %DEV
> 	parent 1:12
> 	prio 40
> 	protocol all
> 	basic match meta(nfmark eq %LOW_WATERMARK)
> 		    and (
> 		    	nbyte("\x0\x1\x2\x3\x4" at 4 layer 2) /* 00 01 02 03 04 (dla fp) */
> 			or u32(ip src 10.0.0.0/8)
> 		    )
> 	flowid 1:20
> 
> 

It does look clean. - btw look at Werners approach on tcng as well.

> > >  - it doesn't get along with my more complicated ematch parsing
> > 
> > Example?
> 
> stuff like nbyte, kmp or regexp rely on quoted strings and those
> would be destroyed if they'd contain whitespaces.

sounds reasonable.

Another thing that would be really neat is to have a iso like cli
(something like what zebra has) so you can go down the parse tree to
say the ematch level and just start typing away these commands.
Should probably be easy to rip off the vtysh stuff off zebra or
use libio or something along those lines to do this.

cheers,
jamal
