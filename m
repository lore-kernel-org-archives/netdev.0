From: Florian Weimer <fw@deneb.enyo.de>
Subject: Re: Route cache performance under stress
Date: Tue, 10 Jun 2003 20:41:00 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <87el21wzb7.fsf@deneb.enyo.de>
References: <008001c32eda$56760830$4a00000a@badass>
	<20030609195652.E35696@shell.cyberus.ca>
	<Pine.LNX.4.51.0306092006420.12038@ns.istop.com>
	<20030609204257.L35799@shell.cyberus.ca>
	<Pine.LNX.4.51.0306092200150.28167@ns.istop.com>
	<20030610061010.Y36963@shell.cyberus.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: ralph+d@istop.com, CIT/Paul <xerox@foonet.net>,
   "'Simon Kirby'" <sim@netnation.com>, "'David S. Miller'" <davem@redhat.com>,
   "netdev@oss.sgi.com" <netdev@oss.sgi.com>,
   "linux-net@vger.kernel.org" <linux-net@vger.kernel.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: Jamal Hadi <hadi@shell.cyberus.ca>
In-Reply-To: <20030610061010.Y36963@shell.cyberus.ca> (Jamal Hadi's message
 of "Tue, 10 Jun 2003 06:53:04 -0400 (EDT)")
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Jamal Hadi <hadi@shell.cyberus.ca> writes:

> Typically, real world is less intense than the lab. Ex: noone sends
> 100Mbps at 64 byte packet size.

Unfortunately, compromised hosts do send such traffic, and DoS victims
receive it. 8-(

You don't want your core routers to break down just because a couple
of the 150,000 hosts in your regional network have been compromised
(think of Slammer) or you are running an IRC server.

> Have you seen how the big boys advertise?

Typical GSR linecards for OC-48 are specified to handle 2 Mpps, but
the switch fabric is reportedly somewhat inert and the router might
choke before that if there are too many linecards involved (I haven't
observed this personally, this just chatter from someone who works
daily with those beasts).  A couple of hundred kpps aren't a problem
for those routers, though, as are 300 Mbit (or was it 400?) of Slammer
traffic (with random destination addresses).

In general, the forwarding performance is nowadays specified in pps
and even flows per second if you look carefully at the data sheets.
Most vendors have learnt that people want routers with comforting
worst-case behavior.  However, you have to read carefully, e.g. a
Catalyst 6500 with Supervisor Engine 1 (instead of 2) can only create
650,000 flows per second, even if it has a much, much higher peak IP
forwarding rate.

(The times of routers which died when confronted with a rapid ICMP
sweep across a /16 are gone for good, I hope.)
