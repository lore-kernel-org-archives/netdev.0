From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PKT_SCHED]: Allow using nfmark as key in U32 classifier.
Date: Mon, 3 Jan 2005 16:02:30 +0100
Message-ID: <20050103150230.GC26856@postel.suug.ch>
References: <20041231110836.GD32419@postel.suug.ch> <1104505142.1048.262.camel@jzny.localdomain> <20041231153930.GN32419@postel.suug.ch> <1104511494.1048.303.camel@jzny.localdomain> <20041231181153.GP32419@postel.suug.ch> <1104526311.1047.379.camel@jzny.localdomain> <20050101121041.GR32419@postel.suug.ch> <1104622164.1048.444.camel@jzny.localdomain> <20050102000612.GU32419@postel.suug.ch> <1104763012.1047.524.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1104763012.1047.524.camel@jzny.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* jamal <1104763012.1047.524.camel@jzny.localdomain> 2005-01-03 09:36
> On Sat, 2005-01-01 at 19:06, Thomas Graf wrote:
> > * jamal <1104622164.1048.444.camel@jzny.localdomain> 2005-01-01 18:29
> > > Does the ematch API include a dump()? I dont think it should - thats the
> > > point i was making. Should be simple.
> > 
> > Yes, although simple ematches are not required to implement dump.
> 
> ok. I realize its optional - but i wouldnt even give the writter of
> ematch the opportunity to write one. Want something more complex? write
> a classifier.

A classifier is at least 300 lines and you lose the ability to use the
logic relations.

> Again allowing for this may be overkill. Just send the same structure
> the ematch needs in exactly the same form it needs it and you dont need
> this. 

Compromise: If change/dump is not provided the api allocates and
memcpy's itself resptively dumps m->data. Simple ematches don't have to
care and can simple access m->data, more complex ematches can implement
their own change/dump. Does that sound beter?

> whats the .link for?

I use list.h to chain ematch_ops and it's better to have it initialized.
