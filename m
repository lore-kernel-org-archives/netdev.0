From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PKT_SCHED]: Allow using nfmark as key in U32 classifier.
Date: Sat, 1 Jan 2005 19:32:30 +0100
Message-ID: <20050101183230.GT32419@postel.suug.ch>
References: <20041229150140.GJ32419@postel.suug.ch> <1104335620.1025.22.camel@jzny.localdomain> <20041230174313.GB32419@postel.suug.ch> <1104469111.1049.219.camel@jzny.localdomain> <20041231110836.GD32419@postel.suug.ch> <1104505142.1048.262.camel@jzny.localdomain> <20041231153930.GN32419@postel.suug.ch> <1104511494.1048.303.camel@jzny.localdomain> <20041231181153.GP32419@postel.suug.ch> <1104526311.1047.379.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1104526311.1047.379.camel@jzny.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* jamal <1104526311.1047.379.camel@jzny.localdomain> 2004-12-31 15:51
> >  T=1 generic selector header
> >
> >  T=2 classifier specific selector header (u32 hashsing stuff goes here)
> >  T=3 ematch 1
> >  T=N ematch N
> 
> I thought we already agreed on the layout:
> SEL2- which may nest E/MATCHEs TLVs. Sel2 not being very different from
> original selector. May be i didnt follow. 

OK, I changed my mind while implementing it and a selector now looks
like this:

Selector TLV:

 +----------------------------+
 | TCA_EMATCH_TREE_HDR        |
 +----------------------------+
 | TCA_EMATCH_TREE_LIST       |
 | +------------------------+ |
 | | T=1 Match 1            | |
 | +------------------------+ |
 | | T=2 Match 2            | |
 | +------------------------+ |
 | | T=N Match N            | |
 | +------------------------+ |
 +----------------------------+

So we can put more into the selector if needed without breaking
compatibility. TCA_EMATCH_TREE_HDR currently contains `nmatches'
specifying N and progid holding the PID you talked about.
The match TLVs must have a continous numbering because I don't
want to define limits as done in the action code.

I'll post an RFC patch tomorrow implementing the API and a
simple ematch.
