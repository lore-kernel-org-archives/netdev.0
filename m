From: Martin Josefsson <gandalf@wlug.westbo.se>
Subject: Re: [Fwd: [ANNOUNCE] Layer-7 Filter for Linux QoS]
Date: 20 May 2003 17:15:03 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1053443703.17386.138.camel@tux.rsn.bth.se>
References: <1053313298.3909.5.camel@rth.ninka.net>
	 <20030519202756.I39498@shell.cyberus.ca> <3EC9B815.4000504@ethanet.com>
	 <20030520080940.E40885@shell.cyberus.ca> <3ECA3E2C.20805@ethanet.com>
	 <20030520105356.U41173@shell.cyberus.ca>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Ethan Sommer <sommere@ethanet.com>, "David S. Miller" <davem@redhat.com>,
   linux-net@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jamal Hadi <hadi@shell.cyberus.ca>
In-Reply-To: <20030520105356.U41173@shell.cyberus.ca>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 2003-05-20 at 17:00, Jamal Hadi wrote:
> On Tue, 20 May 2003, Ethan Sommer wrote:
> 
> > Nope. I need to strip out all the nulls from the packet, or any posix
> > regex parser will think the string ends at the first null. (so protocols
> > which use null's will be difficult/impossible to identify)
> 
> Ok, i see your dilema. How does snort do it? I dont think copying the
> packet is the right way to do it. Could the null NOT be considered as
> something speacial unless explicitly stated?

Maybe make it take a length parameter and if it's zero treat null's like
all other algorithms do and it's non-zero use the length instead.
Then you can hide it in a wrapper function for the "normal" case that
just calls the actual search-function but with 0 as length.

> >
> > I could modify the regexec function to take a length, but then it
> > wouldn't be the posix regexec prototype and I was hopeing someone would
> > add those to the common library of kernel functions, so others could use
> > them. (and hence make it easier to maintain.)
> >
> 
> This would be the first start. Check with the netfilter folks who are
> famous for creating bread slicers - they may already have something along
> these lines.
> I am actually  interested in the kernel variant of such a
> library. Actually once you have the library (which is efficient) we could
> work together. I have some stuff cooking (and lotsa opinions on what i
> would like to see in it that you could consider as requirements).

Well we don't have a that big bread slicer (yet) but take a look at
libqsearch, it is a library for searching and has been ported to the
linux kernel by the author. It has support for various algorithms that
have diffrent capabilities, unfortunately I don't think it has an
algorithm that has support for regexp yet (the framework is there, ie
the flag that says an algorithm supports regexp).
It's modular and I don't think it should be that hard to add an regexp
algorithm.
It looks quite nice and it can search for multiple strings at the same
time and call diffrent callbacks depending on which string matched.

-- 
/Martin
