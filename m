From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Proposed linux kernel changes : scaling  tcp/ip stack
Date: Thu, 03 Jun 2010 11:14:00 +0200
Message-ID: <1275556440.2456.19.camel@edumazet-laptop>
References: <FDFFEFAB-A741-4232-821E-17BFAE5CAFAC@earthlink.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Mitchell Erblich <erblichs@earthlink.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:58123 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756594Ab0FCJOG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Jun 2010 05:14:06 -0400
Received: by fxm8 with SMTP id 8so2530879fxm.19
        for <netdev@vger.kernel.org>; Thu, 03 Jun 2010 02:14:03 -0700 (PDT)
In-Reply-To: <FDFFEFAB-A741-4232-821E-17BFAE5CAFAC@earthlink.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 03 juin 2010 =C3=A0 01:16 -0700, Mitchell Erblich a =C3=A9crit=
 :
> To whom it may concern,
>=20
> First, my assumption is to keep this discussion local to just a few t=
cp/ip
> developers to see if there is any consensus that the below is a logic=
al=20
> approach. Please also pass this email if there is a "owner(s)" of thi=
s stack
> to identify if a case exists for the below possible changes.
>=20
> I am not currently on the linux kernel mail group.
> 		=09
> I have experience with modifications of the Linux tcp/ip stack, and h=
ave
> merged the changes into the company's local tree and left the possibl=
e=20
> global integration to others.
>=20
> I have been approached by a number of companies about scaling the
> stack with the assumption of a number of cpu cores. At present, I fin=
d extra
> time on my hands and am considering looking into this area on my own.
>=20
> The first assumption is that if extra cores are available, that a sin=
gle
> received homogeneous flow of a large number of packets/segments per
> second (pps) can be split into non-equal flows. This split can in eff=
ect
> allow a larger recv'd pps rate at the same core load while splitting =
off
> other workloads, such as xmit'ing pure ACKs.
>=20
> Simply, again assuming Amdahl's law (and not looking to equalize the =
load
> between cores), and creating logical separations where in a many core=
=20
> system, different cores could have new kernel threads  that operate i=
n=20
> parallel within the tcp/ip stack. The initial separation points would=
 be at=20
> the ip/tcp layer boundry and where any recv'd sk/pkt would generate s=
ome=20
> form of output.
>=20
> The ip/tcp layer would be split like the vintage AT&T STREAMs protoco=
l,
> with some form of queuing & scheduling, would be needed. In addition,
> the queuing/schedullng of other kernel threads would occur within ip =
& tcp
> to separate the I/O.
>=20
> A possible validation test is to identify the max recv'd pps rate wit=
hin the
> tcp/ip modules within normal flow TCP established state with normal o=
rder=20
> of say 64byte non fragmented segments, before and after each=20
> incremental change. Or the same rate with fewer core/cpu cycles.
>=20
> I am willing to have a private git Linux.org tree that concentrates p=
roposed
> changes into this tree and if there is willingness, a seen want/need =
then identify
> how to implement the merge.

Hi Mitchell

We work everyday to improve network stack, and standard linux tree is
pretty scalable, you dont need to setup a separate git tree for that.

Our beloved maintainer David S. Miller handles two trees, net-2.6 and
net-next-2.6 where we put all our changes.

http://git.kernel.org/?p=3Dlinux/kernel/git/davem/net-next-2.6.git
git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next-2.6.git

I suggest you read the last patches (say .. about 10.000 of them), to
have an idea of things we did during last years.

keywords : RCU, multiqueue, RPS, percpu data, lockless algos, cache lin=
e
placement...

Its nice to see another man joining the team !

Thanks


