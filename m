From: Mark Smith <lk-netdev@lk-netdev.nosense.org>
Subject: Re: about packets forwarding
Date: Wed, 2 Sep 2009 20:18:00 +0930
Message-ID: <20090902201800.1dbb4988.lk-netdev@lk-netdev.nosense.org>
References: <f4f837ab0907220706g1129a1cbv7dfad944e5bada16@mail.gmail.com>
	<f4f837ab0909020127o3359ed03j224ef51a0673bcd9@mail.gmail.com>
	<f4f837ab0909020203w67bcba16pbb317c587c58e70f@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: wu xiaofei <lampsu@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.adam.net.au ([202.136.110.251]:55793 "EHLO
	smtp2.adam.net.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751071AbZIBKsE convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Sep 2009 06:48:04 -0400
In-Reply-To: <f4f837ab0909020203w67bcba16pbb317c587c58e70f@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2 Sep 2009 17:03:42 +0800
wu xiaofei <lampsu@gmail.com> wrote:

> Hello,
>=20
> I have something to ask here.
>=20
> The topology of the network is as follows.
> There are six Nodes (A, B, C, D, M, N).
>=20
> =A0 M
> =A0 |
> =A0 A
> =A0/ \
> B=A0=A0 D
> =A0\ /
> =A0 C
> =A0 |
> =A0 N
>=20
> M-A, C-N are wired links.
> A-B, B-C, A-D, D-C are wireless links.
>=20
> Node M wnats to communicate with node N. Because the wireless links
> are not very reliable, I want to forward the packets through A-B-C an=
d
> A-D-C simultaneously (When Node A receives packets(from Node M) from
> its wired interface eth0, It will forward the same packets to its
> wireless interfaces wlan0 and wlan1 simultaneously) . How to implemen=
t
> this?
>=20

Packets being duplicated in this manner is generally considered an
error - protocols are designed to deal with it, but only as an error
robustness mechanism. In other words, it won't break anything, but
performance is very likely to suffer.

The Internet protocols are designed on the assumption of a low
possibility of packet loss (1 in 100)- they only assume each
link in the path will have an error detection mechanism (and drop them
when errors occur), but not an error correction mechanism. If the
possibility of packet loss is high (1 in 10), then it is expected that
the link layer itself will implement error detection and recovery.

You can read about the design philosophies of the Internet Protocols in
the following paper:

"The Design Philosophy of the DARPA Internet Protocols"

http://www.acm.org/sigs/sigcomm/ccr/archive/1995/jan95/ccr-9501-clark.p=
df

As for your specific scenario, to increase the reliablity of the
individual wireless links, you could look into running X.25 over LAPB
over Ethernet (LAPB over Ethernet driver kernel option). LAPB adds the
error correction/recovery that's normally not present with Ethernet, an=
d
X.25 might be necessary to be carry IP frames. According to the help
for that driver, it creates a /dev/labp0 interface, which you may then
alternatively be able to direct pppd to use, which would then allow you
to carry IP over PPP over LAPB over Ethernet, again gaining link layer
reliability below IP.

It's purely a theoretical suggestion though, as I haven't ever tried it=
=2E

Regards,
Mark.
