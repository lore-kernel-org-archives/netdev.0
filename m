From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [RFC] batched tc to improve change throughput
Date: Sat, 12 Feb 2005 15:29:43 +0100
Message-ID: <20050212142943.GF31837@postel.suug.ch>
References: <20050118145830.GS26856@postel.suug.ch> <1106144009.1047.989.camel@jzny.localdomain> <20050119165421.GB26856@postel.suug.ch> <1106232168.1041.125.camel@jzny.localdomain> <20050120153559.GG26856@postel.suug.ch> <1106576005.1652.1292.camel@jzny.localdomain> <20050124150634.GT23931@postel.suug.ch> <1106747313.1107.7.camel@jzny.localdomain> <1108134446.5523.22.camel@ganymede> <1108215923.1126.132.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Dan Siemon <dan@coverfire.com>, netdev@oss.sgi.com
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1108215923.1126.132.camel@jzny.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> > I'd like to make a little plug for my Linux QoS Library (LQL) [1]
> > project.  LQL provides an abstraction of the kernel QoS features.  Full
> > API documentation is available from the website.

I've been looking at this before and I do like your approach. The
license prevents me from really using it buts that's not your problem.
What I really like about it are the bindings to other languages, that's
definitely a good thing.

* jamal <1108215923.1126.132.camel@jzny.localdomain> 2005-02-12 08:45
> What would be really interesting is to see (gulp) a SOAP/xml interface
> on top of this. Is this something you can do with those "bindings"?

Indeed, an xml interface would be really nice to have. I've been
implementing some xml bits for links and neighbour in libnl so far
but i'm not yet sure about the exact format until I'm sure there is
no existing format that would fit us.

> It seems to me from a library perspective, youa nd Thomas may have to
> sync.

Sure, I'm willing to sync as long as the result stays LGPL. The
architectures are quite different so I think the only code we can
share or convert are the actual qdisc/class/filter modules to parse
the netlink messages and do various translations of types and flags etc.

> And restricting to just QoS maybe be a limitation (netlink is the
> friend you are looking for; so from networking perspective, give them 
> GUI clikers ways to set routes, static IPSEC SAs etc). Oh and it would
> be interesting to have events (see that link come up down etc)

Although it's possible to receive multicast group messages I haven't
added a specific API into it and you have to do the demuxing
of the various messages types yourself for now (via valid message
callback).

Maybe a quick status report about what's done:
 - core netlink API: 80%, lacks better support for non-blocking sockets
                     and for multicast grouping messages
 - link: 100%
 - neighbour: 100%
 - route: 70%, msg parser and attribte setting done, still lacks a good
          dumping procedure and message building
 - address: partial patch received which works more or less, someone has
            started working on it again
 - rule: 0%
 - tc 50% still lacks implementations for various qdiscs and classifiers

I haven't touched any other netlink users such as xfrm but those should
be easier to do actually, rtnetlink is the biggest ;->

I've been spending some time on documenting the existing API and
about 40% is done by now.  You can have a look at the current
progress of the documentation, the neighbour and link documentation
is nearly finished and gives you the best impression.

	http://people.suug.ch/~tgr/libnl/doc/modules.html
