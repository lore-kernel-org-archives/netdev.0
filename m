From: "Jeff Haran" <jharan@bytemobile.com>
Subject: RE: forwarding pings out ingress interface
Date: Thu, 2 Jun 2011 13:33:04 -0700
Message-ID: <6F5DE7538AFCDA45A114F5E7510424A7027D839E@hq-exchange01.bytemobile.com>
References: <6F5DE7538AFCDA45A114F5E7510424A7027D8388@hq-exchange01.bytemobile.com> <4DE7E8AA.20000@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <netdev@vger.kernel.org>
To: =?iso-8859-1?Q?Nicolas_de_Peslo=FCan?=
	<nicolas.2p.debian@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ironport.bytemobile.com ([12.153.136.13]:45113 "EHLO
	ironport.bytemobile.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753785Ab1FBUdZ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Jun 2011 16:33:25 -0400
Content-class: urn:content-classes:message
In-Reply-To: <4DE7E8AA.20000@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: Nicolas de Peslo=FCan [mailto:nicolas.2p.debian@gmail.com]
> Sent: Thursday, June 02, 2011 12:47 PM
> To: Jeff Haran
> Cc: netdev@vger.kernel.org
> Subject: Re: forwarding pings out ingress interface
>=20
> Le 02/06/2011 21:10, Jeff Haran a =E9crit :
> > Running Redhat Enterprize 6.0, seeing the following behavior.
> >
> > Two Ethernet network segments: 172.30/16 and 169.254.160/24.
> >
> > Three "devices":
> >
> > [linux] is the blade running RHEL6.0. It has multiple network inter=
faces
> > and has IP forwarding enabled.
> > [host] is an IP host of some sort.
> > [lb] is an L3 load balancer.
> >
> > They are connected like so:
> >
> > [host] 172.30.0.254<->  172.30.0.2 [lb] 169.254.160.20<->  169.254.=
160.1
> > [linux]
> >
> > I have not shown the other network interfaces that [linux] is attac=
hed
> > to for brevity in the diagram.
> >
> > One of the peculiarities of [lb] is if [host] pings it at 172.30.0.=
2, it
> > will not respond to the ping itself but instead forward the ping to
> > [linux]. I realize this is broken, but I have to deal with it (its
> > cooked into [lb]'s silicon). [lb]'s vendor assures me that if [linu=
x]
> > would only forward the ping back to [lb] out the same interface it =
came
> > in on, then [lb] will generate a ping response back to [host].
> >
> > My problem is [linux] won't forward the ping back to [lb]. [linux] =
has a
> > route to 172.30/16 out the interface that connects it to [lb] and I=
 can
> > see from tcpdump that [linux] is getting the ICMP Echo requests wit=
h
> > source address 172.30.0.254 and destination address 172.30.0.2, but
> > nothing gets transmitted out that interface in response.
>=20
> As per RFC3927, section 2.6.2 "[a] host MUST NOT send a packet with a=
n IPv4
> Link-Local destination
> address to any router for forwarding." Your linux host use 169.254.16=
0/24,
> which is in the IPv4
> Link-Local range. So it is normal for your linux host not to reply to=
 a ping
> request coming from
> outside of the local subnet.

Nicolas,

Thanks for the response, but what you are saying above is not the case.=
 The source and destination IP addresses in the ping are both on the 17=
2.30/64 net, which is routable. [linux] has assigned addresses in the l=
ink-local  local range to its own interfaces, but in this case I just w=
ant [linux] to forward the IP packet unmodified (except for decrementin=
g the TTL and the MAC addresses before the IP packet, of course). Plus,=
 as I mentioned above [linux] forwards these packets fine if I set to r=
oute to the 172.30/16 nets out another of its interfaces.

The issue seems to be related to forwarding a packet out the same inter=
face it came in on, but I am guessing here.
=20
> Why do you use an IP in the link local range? For as far as I remembe=
r (but I
> failed to find the
> exact section), this RFC also forbid static configuration of an IP in=
 this range.
>=20
> 	Nicolas.

Same reason everybody uses these things. These networks are on chassis =
backplanes and they are supposed to be hidden from the outside world, p=
articularly we don't want the packets with 169.254 net addresses in the=
m to get routed outside of those networks. The 169.254 network is the c=
losest thing in IPv4 that comes to providing this functionality.

Jeff Haran



