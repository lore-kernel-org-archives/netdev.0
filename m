From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH] PKT_SCHED: dsmark must take care of shared/cloned skbs
Date: Wed, 22 Dec 2004 14:50:30 +0100
Message-ID: <20041222135030.GD7884@postel.suug.ch>
References: <20041218170017.GH17998@postel.suug.ch> <1103487827.1048.188.camel@jzny.localdomain> <20041219203641.GL17998@postel.suug.ch> <41C687EE.1090205@trash.net> <1103552026.1048.324.camel@jzny.localdomain> <20041220170222.5ee14588.davem@davemloft.net> <1103721246.1093.39.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, kaber@trash.net,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1103721246.1093.39.camel@jzny.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* jamal <1103721246.1093.39.camel@jzny.localdomain> 2004-12-22 08:14
> On Mon, 2004-12-20 at 20:02, David S. Miller wrote:
> > We have a similar problem with TSO and some gigabit cards whose
> > drivers muck with the iphdr->tot_len field on transmit.  I still
> > am not sure how I want to address that case yet.  Since transmitted
> > TCP data packets are always shared/cloned, we'll have to do a data
> > copy on every TSO send on these cards which frankly nullifies much
> > of the performance gain TSO gives.  If we end of fixing it via a copy
> > we'll probably need to seriously consider not doing TSO unless we
> > are doing sendfile.
> 
> Ok, makes sense. I can see how TSO may not be useful if you have to
> copy. I suppose NICS with hardware based retransmits will behave
> differently.

I think we should move all packet manngling to be an action and warn
about the loss of performance. We might be able to add a fast path for
simple modifications such as dsmark dscp maping and other simple header
modifications by not copying but mangle the fragment itself assuming we
can accept some drawbacks with packet sockets. More advanced mangling
as done by pedit is less of a problem since it will likely be used
in combination with heavy filtering but we could of course do some
analysis of the edit request and go the fast path under some
circumstances.
