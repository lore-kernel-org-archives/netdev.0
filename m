From: "John A. Sullivan III" <jsullivan@opensourcedevel.com>
Subject: Re: tc filter show not displaying anything
Date: Fri, 16 Dec 2011 00:39:29 -0500
Message-ID: <1324013969.8451.326.camel@denise.theartistscloset.com>
References: <1324010915.8451.319.camel@denise.theartistscloset.com>
	 <1324012627.2562.26.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.perfora.net ([74.208.4.195]:58440 "EHLO mout.perfora.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750821Ab1LPFje convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Dec 2011 00:39:34 -0500
In-Reply-To: <1324012627.2562.26.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2011-12-16 at 06:17 +0100, Eric Dumazet wrote:
> Le jeudi 15 d=C3=A9cembre 2011 =C3=A0 23:48 -0500, John A. Sullivan I=
II a =C3=A9crit :
> > Hello, all.  I'm starting to feel really stupid and showing my newb=
idity
> > to tc.  I do a:
> > tc filter show dev eth1
> > and nothing is displayed but I suspect the filter is there because =
if I
> > try to add it again, the kernel complains with:
> > RTNETLINK answers: File exists
> > We have an error talking to the kernel
> >=20
> > Here is what I have put together so far (disregard the silly ports =
- it
> > is just for netcat testing):
> >=20
> > tc qdisc add dev eth1 root handle 1: hfsc default 20
> > tc class add dev eth1 parent 1: classid 1:1 hfsc sc rate 1490kbit u=
l rate 1490kbit
> > tc class add dev eth1 parent 1:1 classid 1:20 hfsc rt rate 800kbit =
ls rate 200kbit
> > tc qdisc add dev eth1 parent 1:20 handle 1201 sfq perturb 10
> > tc class add dev eth1 parent 1:1 classid 1:10 hfsc rt umax 16000kbi=
t dmax 13ms rate 400kbit ls rate 1000kbit
> > tc qdisc add dev eth1 parent 1:10 handle 1101 sfq perturb 10
> > iptables -t mangle -A POSTROUTING  -p 6 --syn --dport 443 -j CONNMA=
RK --set-mark 0x10
> > iptables -t mangle -A POSTROUTING  -p 6 -j CONNMARK --restore-mark
> >=20
> > I then did:
> >=20
> > root@testswitch01:~# tc filter add dev eth1 parent 1:1 protocol ip =
prio 1 handle 0x10 fw flowid 1:10
> > root@testswitch01:~# tc filter show dev eth1
> > root@testswitch01:~# tc filter show parent 1:1
> >=20
> > What simple, practical thing did I mangle? Thanks - John
>=20
> Minor point (since John already replied) :  "sfq perturb 10" means yo=
u
> risk out or order packets perturbation every 10 seconds. This can rea=
lly
> hurt TCP sessions.
>=20
> Maybe we should "fix" this problem for good in SFQ.
>=20
>=20
>=20
Ouch! That was right out of the book so to speak.  Thanks for pointing
it out - now I see it is right in the man page.  Is best practice to no=
t
perturb and live with the potentially unbalanced queues or just to set
it even higher? Thanks - John
