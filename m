From: jamal <hadi@cyberus.ca>
Subject: Re: Longstanding networking / SMP issue? (duplextest)
Date: Thu, 20 Feb 2003 07:43:57 -0500 (EST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030220074148.U28230@shell.cyberus.ca>
References: <20030219203342.P28230@shell.cyberus.ca> <20030220020527.GA12748@netnation.com>
 <20030220073513.E28230@shell.cyberus.ca>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Simon Kirby <sim@netnation.com>
In-Reply-To: <20030220073513.E28230@shell.cyberus.ca>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Pls ignore this. Wasnt meant to go to netdev - this is what happens
when i get too lazy (i invoked it from pine so i could cunpaste it and
then forgot to delete it ;->).

cheers,
jamal

On Thu, 20 Feb 2003, jamal wrote:

>
> I got you. I think its a clever idea. You have better chances if you
> make your packets larger.
> Netdev is the network developers mailing list at netdev@oss.sgi.com
> Linux-net is network users mailing list;
>
> cheers,
> jamal
>
> On Wed, 19 Feb 2003, Simon Kirby wrote:
>
> > On Wed, Feb 19, 2003 at 08:40:47PM -0500, jamal wrote:
> >
> > > Hi, could you please either posting or ccing netdev on network related
> > > issues? There are a lot of people who could help you but are not
> > > subscribed to lk.
> >
> > Is netdev separate from linux-net?  If so, where is it? :)
> >
> > > I dont have an answer for you. I think testing a different card like
> > > Dave says would be a good start. I am curious about the theory of
> > > operation of your program; by duplex mismatch i take it you mean one end
> > > has one speed setting but the other has a conflicting one?
> > > If thats so i am not sure i understand why sending a burst of packets
> > > and waiting for responses catches this problem. Are you saying
> > > you could successfully send but fail to receive? I dont see the connection
> > > and i am curious.
> >
> > Here's the story...
> >
> > Once upon a time, Donald wrote (or helped write, I don't know) the eepro100
> > driver.  Because Intel had so many variants of the eepro100, it was
> > difficult to implement link autonegotiation because different cards had
> > the link state detection wired to different pins.  Even today, the eepro100
> > driver doesn't seem to autonegotiate with any of the switches I've tried
> > it with.  (10/100 autonegotiates fine, but the duplex does not.)
> >
> > To get around this problem, we had to force our switch ports to 100/full
> > and force the eepro100 driver to 100/full also.  This works well, but
> > because we have hundreds of boxes running diferent OSs and we tend to
> > move things aroud fairly often, it's easy to forget to set up the port
> > properly.  When this happens, everything appears to work, but depending
> > on timing, some packets are dropped due to one side believing there is a
> > collision while other side sees no problem.  (This assumes you understand
> > how Ethernet works -- if not, let me know!)
> >
> > The timing required to hit the packet loss is actually quite important.
> > Web site visitors can often download at fairly high speeds over the
> > Internet (600 kB/sec, for example) from a machine with a duplex mismatch,
> > but internally (on the same LAN), transfer rates can be as low as 20
> > kB/sec, although usually about 60 kB/sec, depending on the number of
> > switches being traversed, luck, etc.
> >
> > The duplextest program attempts to set up a timing situation that
> > exploits the half-collision scenario by sending multiple echo packets at
> > once, so that the first will be on the way back while the latter are
> > still being sent.  "ping -f" doesn't work for this because it always uses
> > a timer and only sends one packet.
> >
> > I hope this explains things...
> >
> > Simon-
> >
> > [        Simon Kirby        ][        Network Operations        ]
> > [     sim@netnation.com     ][     NetNation Communications     ]
> > [  Opinions expressed are not necessarily those of my employer. ]
> >
>
>
>
