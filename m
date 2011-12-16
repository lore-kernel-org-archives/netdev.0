From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: tc filter show not displaying anything
Date: Fri, 16 Dec 2011 06:17:07 +0100
Message-ID: <1324012627.2562.26.camel@edumazet-laptop>
References: <1324010915.8451.319.camel@denise.theartistscloset.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: "John A. Sullivan III" <jsullivan@opensourcedevel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f42.google.com ([74.125.82.42]:39524 "EHLO
	mail-ww0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750900Ab1LPFYx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Dec 2011 00:24:53 -0500
Received: by wgbds13 with SMTP id ds13so2403423wgb.1
        for <netdev@vger.kernel.org>; Thu, 15 Dec 2011 21:24:51 -0800 (PST)
In-Reply-To: <1324010915.8451.319.camel@denise.theartistscloset.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 15 d=C3=A9cembre 2011 =C3=A0 23:48 -0500, John A. Sullivan III=
 a =C3=A9crit :
> Hello, all.  I'm starting to feel really stupid and showing my newbid=
ity
> to tc.  I do a:
> tc filter show dev eth1
> and nothing is displayed but I suspect the filter is there because if=
 I
> try to add it again, the kernel complains with:
> RTNETLINK answers: File exists
> We have an error talking to the kernel
>=20
> Here is what I have put together so far (disregard the silly ports - =
it
> is just for netcat testing):
>=20
> tc qdisc add dev eth1 root handle 1: hfsc default 20
> tc class add dev eth1 parent 1: classid 1:1 hfsc sc rate 1490kbit ul =
rate 1490kbit
> tc class add dev eth1 parent 1:1 classid 1:20 hfsc rt rate 800kbit ls=
 rate 200kbit
> tc qdisc add dev eth1 parent 1:20 handle 1201 sfq perturb 10
> tc class add dev eth1 parent 1:1 classid 1:10 hfsc rt umax 16000kbit =
dmax 13ms rate 400kbit ls rate 1000kbit
> tc qdisc add dev eth1 parent 1:10 handle 1101 sfq perturb 10
> iptables -t mangle -A POSTROUTING  -p 6 --syn --dport 443 -j CONNMARK=
 --set-mark 0x10
> iptables -t mangle -A POSTROUTING  -p 6 -j CONNMARK --restore-mark
>=20
> I then did:
>=20
> root@testswitch01:~# tc filter add dev eth1 parent 1:1 protocol ip pr=
io 1 handle 0x10 fw flowid 1:10
> root@testswitch01:~# tc filter show dev eth1
> root@testswitch01:~# tc filter show parent 1:1
>=20
> What simple, practical thing did I mangle? Thanks - John

Minor point (since John already replied) :  "sfq perturb 10" means you
risk out or order packets perturbation every 10 seconds. This can reall=
y
hurt TCP sessions.

Maybe we should "fix" this problem for good in SFQ.
