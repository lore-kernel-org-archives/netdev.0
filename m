From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [RFC] neighbour tables configuration via rtnetlink
Date: Tue, 8 Mar 2005 02:37:18 +0100
Message-ID: <20050308013718.GZ31837@postel.suug.ch>
References: <20050305172257.GN31837@postel.suug.ch> <1110202499.1094.1371.camel@jzny.localdomain> <20050307142622.GT31837@postel.suug.ch> <1110240219.1044.83.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1110240219.1044.83.camel@jzny.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* jamal <1110240219.1044.83.camel@jzny.localdomain> 2005-03-07 19:03
> On Mon, 2005-03-07 at 09:26, Thomas Graf wrote:
> > Yes, I think so as well but I really want to avoid putting effort into it
> > and then see it replaced with something else. I think Herbert once thought
> > about moving some of the rtnetlink stuff into a separate family and
> > restructuring the whole thing. Still plans there Herbert?
> 
> You will still need to grab the rtnl - so probably not much value in
> creating a new netlink proto.

I think so too, still it was worth deploying my sensors scanning for
possible changes to make sure the planned effort is worth it. :->

> Yes, i think you are on the right track as far as using xnl. And if you
> do that endianness issues dont exist (since XML is ascii). I would
> advice (like i have many times on this) to not invent a protocol -
> reusing something like netconf is the best approach. My understanding of
> netconf though is a little dissapointing in that it does not do events
> in the current version they are working on. I think events are supposed
> to come post version 1.0 of the protocol.

Absolutely, I plan to be compatible to as many existing protocols as
possible. The conceptual idea behind is to add another abstraction
layer before that protocol and have XSLT do the transformation into
those protocols.

The path could look like this:

    (netlink)  (API/daemon)    (XSLT)
Kernel  ->  libnl  ->  libnl_XML -> netconf

I left out the byte order issues here because I'm not yet sure how
to solve them although as stated already, using XSLT would be one
possible path to follow.

> I believe there is a open source project which does netconf already;
> maybe all they need is just your library and xml interface ... I will
> look it up and send you some pointers. 

You probably mean Yenca, I'm looking into it but it uses ioctl for
configuration and only implements a small subset of the functionality.
I've CC'ed Benjamin Zores which is stated as the author in the source
files.

> BTW, what happened in the discussion with the gent who was doing SOAP
> (or was going to do SOAP?)

The discussion somewhat stalled but I didn't forget about it. Having
the above architecture would allow to simply put the XML based
architecture indepedant change requests into SOAP envelopes and distribute
them.
