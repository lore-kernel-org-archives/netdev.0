From: Florian Weimer <fw@deneb.enyo.de>
Subject: Re: Real World Routers 8-)
Date: Wed, 11 Jun 2003 20:41:51 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <877k7scv80.fsf_-_@deneb.enyo.de>
References: <008001c32eda$56760830$4a00000a@badass>
	<20030609195652.E35696@shell.cyberus.ca>
	<Pine.LNX.4.51.0306092006420.12038@ns.istop.com>
	<20030609204257.L35799@shell.cyberus.ca>
	<Pine.LNX.4.51.0306092200150.28167@ns.istop.com>
	<20030610061010.Y36963@shell.cyberus.ca>
	<87el21wzb7.fsf@deneb.enyo.de>
	<20030611074007.S39760@shell.cyberus.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: quoted-printable
Cc: ralph+d@istop.com, CIT/Paul <xerox@foonet.net>,
   "'Simon Kirby'" <sim@netnation.com>, "'David S. Miller'" <davem@redhat.com>,
   "netdev@oss.sgi.com" <netdev@oss.sgi.com>,
   "linux-net@vger.kernel.org" <linux-net@vger.kernel.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: Jamal Hadi <hadi@shell.cyberus.ca>
In-Reply-To: <20030611074007.S39760@shell.cyberus.ca> (Jamal Hadi's message
 of "Wed, 11 Jun 2003 07:47:44 -0400 (EDT)")
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Jamal Hadi <hadi@shell.cyberus.ca> writes:

> Ok, this is interesting. I have never seen the flows per second
> used for simple L3 forwading. I have seen them being used for NAT or
> firewalling.

Some vendors still sell flow-based routers, and you should be able to
get this numbers if the vendor doesn't try to scam you.

> Looking at the sprint traffic patterns, i think flows/sec is a
> meaningful metric.

It's important to look at this number when buying a router, but I
still think that stateless IP fowarding is the way to go even if you
haven't got specialized hardware (TCAM).

>> Most vendors have learnt that people want routers with comforting
>> worst-case behavior.  However, you have to read carefully, e.g. a
>> Catalyst 6500 with Supervisor Engine 1 (instead of 2) can only create
>> 650,000 flows per second, even if it has a much, much higher peak IP
>> forwarding rate.
>>
>
> So 2Mpps of 650Kflows/sec ?

Exactly.  (You can use a different Supervisor Engine and get stateless
IP switching at 2 Mpps, at least according to the data sheets.)

> We should be able to punish specific misbehaving flows.

This is quite difficult because misbehaving flows often consist of a
single packet.  Managing state for such flows is a waste, but you
hardly can now this when you have to decide whether you want to create
a new flow or not.

If you want to punish per-interface flows, forget it.  Most routers
are not sufficiently multi-homed to make a difference, and attacks
often hit routers on multiple interfaces.

> Do you know if any routers are implementing proper DOS tracebacks to
> allow for inserting drop filters?

You mean IP Pushback?  I haven't seen it on production routers, and
I'm pretty sure that no one uses it yet.

Flow-based traffic monitoring is available on most routers nowadays
(often sampled, though), even on routers that perform stateless IP
forwarding.

Anyway, just dropping packets locally doesn't help you *that* much,
you need cooperation of your upstream (and automated cooperation =E0 la
IP Pushback is still far, far away, I presume).
