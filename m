From: sebastien <sriliam@free.fr>
Subject: iproute2 : unambiguous reading.
Date: Sat, 18 Jul 2009 11:43:16 +0200
Message-ID: <1247910196.10953.84.camel@lya14-2-82-232-125-204>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org, netfilter@vger.kernel.org
Return-path: <netfilter-owner@vger.kernel.org>
Sender: netfilter-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

	First, thanks for all job done on that community in particular, and th=
e
others free ones in a more general way.

	I don't know where should be the right place of this remark and put
this in netdev and netfilter vger's mailing list : hope this will be
usefull.



Legacy :

	We, at my house work, have a non-free software which can be reach from
network : client/server architecture. I will call it "network soft".

	For obscure reasons, we have 2 networks and 2 adsl box for this
purpose : let's say that network1 is a 192.168.0.0/24 with an adsl mode=
m
gateway (gateway1 : 192.168.0.1) and network2 is a 192.168.1.0/24 with
another adsl modem gateway (gateway2 : 192.168.1.1).

	Network1 and network2 are Virtualy Laned by an hp switch and acts like
2 physically separed networks : all is ethernet however.

	"Network Soft" is on network1. People who wants to use it from network=
2
must reach network1 via gateway1 and gateway2, using outside network1
and network2 links. Thoses who are familar with "Fernand Renaud" jokes
will understand the "22 =C3=A0 Asni=C3=A8res" situation.



Changes to the legacy :

	We are not allowed to make an unique network, so I took a PII with two
ethernet cards and put a linux box on that 600 BogoMips !

	Two Ip adress on the PII box : one for network1 (eth0 : 192.168.0.2)
and one for network2 (eth1 : 192.168.1.2).

	I read howtos and other material and found that the maintainer of
Debian didn't compile the routing ease in iptable and says that this is
for iproute2.

	Ok, I read more about this and go on. All I want is that packets from
network2 and destined to "network soft" and packets from "network soft"
and destined to network2 goes across the ethernet cards on the PII box.
All other packets are respectively send to the two gateways : gateway1
for network1 and gateway2 for network2.



_*_ INFORMATION _*_ :

	Saying to the PII box that all traffic from network1 to outside world
uses gateway1 and that all traffic from network2 to outside world uses
gateway2 was really easy and simple. I played with default route on
clients on network1 and network2 and two rules in iproute2 : one for
network1 and another for network2, less than ten minutes !

	I surprisingly spent many hours to join the to networks via the PII
box. All I have to say is that Packets from "network soft" and destined
to network2 must go accross from ethernet1 in network1 to ethernet2 in
network2 and reciprocaly for packets from network2 destined to "network
soft". So, why  that wasted time ? What does I forgot ?


	I re-read many times iproute2 man pages and It didn't work as I
expected. I first make two routing commands :

	ip route from 192.168.0.0/24 to 192.168.1.0/24 via 192.168.1.2 table
network1

	ip route from 192.168.1.0/24 to 192.168.0.0/24 via 192.168.0.2 table
network2

	Which does _not_ work. I supposed that linux was able to see that "fro=
m
192.168.0.0/24 to 192.168.1.0/24" concerning all packets, whatever they
came in ethernet1 (network1) or in ethernet2 (network2), adjusting the
route when according to cause 192.168.0.2 is on ethernet1 and
192.168.1.2 is on ethernet2.

	I added dev after the from/to directive but the device was conserved
for the next via argument and ip says that there were no such device so
I added after "via" the name of the concerned interface, and says
something like :=20

	ip route from 192.168.0.0/24 to 192.168.1.0/24 via 192.168.1.2 dev eth=
1
table network1

	ip route from 192.168.1.0/24 to 192.168.0.0/24 via 192.168.0.2 dev eth=
0
table network2

	Which doesn't worked too. Ip considers that we are talking about the
same device for the two arguments from/to and via !


	This fixed correctly what I wanted :

	ip route from 192.168.0.0/24 to 192.168.1.0/24 dev eth0 via 192.168.1.=
2
dev eth1 table network1

	ip route from 192.168.1.0/24 to 192.168.0.0/24 dev eth1 via 192.168.0.=
2
dev eth0 table network2

	When repeating the name of the device, it works : this is not well
documented in man pages or other text.



NOTE :
	One can see that eth0 is the ethernet1 in network1 and eth1 is
ethernet2 in network2.



DISCUSSION :

	It's probably an evidence for you hackers that we must repeat the name
for the device in order to get accross one of it to another one but it
was not an evidence for me.

	My remark goes to be better documented of that way of thinking : what
are your opinions about that ?

See ya.
Best regards.


