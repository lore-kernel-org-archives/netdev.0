From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [BUG] linux-2.6.26.7 : loading of sch_cbq is stuck
Date: Tue, 04 Nov 2008 15:31:38 +0100
Message-ID: <49105CCA.1040903@cosmosbay.com>
References: <491027B9.2090403@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	Jarek Poplawski <jarkao2@gmail.com>
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([86.65.150.130]:34587 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752238AbYKDObw convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Nov 2008 09:31:52 -0500
In-Reply-To: <491027B9.2090403@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet a =E9crit :
> Hi all
>=20
> Just found this problem on linux-2.6.26.7 when trying to add cbq on e=
th0
>=20
> /proc/modules hangs too
>=20
> root     12117  0.0  0.0   1560   360 pts/1    D+   11:07   0:00 lsmo=
d
> root     10361  0.0  0.0   1996   696 pts/0    D+   11:05   0:00 tc=20
> qdisc add dev eth0 root handle 1: cbq avpkt 1000 rate 100Mbit bandwid=
th=20
> 100Mbit
> root     10362  0.0  0.0      0     0 ?        S<   11:05   0:00 [khe=
lper]
> root     10363  0.0  0.0   1592   588 ?        R    11:05   0:00=20
> /sbin/modprobe -q -- sch_cbq
> root     10364  0.0  0.0      0     0 ?        S<   11:05   0:00=20
> [kstopmachine]
> root     10365  0.0  0.0      0     0 ?        Z<   11:05   0:00=20
> [kstopmachine] <defunct>
> root     10366  0.0  0.0      0     0 ?        Z<   11:05   0:00=20
> [kstopmachine] <defunct>
> root     10367  0.0  0.0      0     0 ?        Z<   11:05   0:00=20
> [kstopmachine] <defunct>
>=20

Well, the answer is : I had a realtime user process that was looping.

Killing it one hour later solved the problem and unlocked all blocked
tasks.

Dont let users run realtime, better let them access hard-reset button..=
=2E


