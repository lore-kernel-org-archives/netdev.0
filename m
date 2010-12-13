From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Fw: [Bug 24842] New: Compatibility issue with uggly Windows
 RFC1323 implementation.
Date: Mon, 13 Dec 2010 18:14:39 +0100
Message-ID: <1292260479.2759.69.camel@edumazet-laptop>
References: <20101213085913.374c1072@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>,
	dmitriy.balakin@nicneiron.ru
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:38180 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752927Ab0LMROo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Dec 2010 12:14:44 -0500
Received: by wyb28 with SMTP id 28so6113129wyb.19
        for <netdev@vger.kernel.org>; Mon, 13 Dec 2010 09:14:43 -0800 (PST)
In-Reply-To: <20101213085913.374c1072@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 13 d=C3=A9cembre 2010 =C3=A0 08:59 -0800, Stephen Hemminger a =
=C3=A9crit :
>=20
> Begin forwarded message:
>=20
> Date: Mon, 13 Dec 2010 14:29:58 GMT
> From: bugzilla-daemon@bugzilla.kernel.org
> To: shemminger@linux-foundation.org
> Subject: [Bug 24842] New: Compatibility issue with uggly Windows RFC1=
323 implementation.
>=20
>=20
> https://bugzilla.kernel.org/show_bug.cgi?id=3D24842
>=20
>            Summary: Compatibility issue with uggly Windows RFC1323
>                     implementation.
>            Product: Networking
>            Version: 2.5
>     Kernel Version: All
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: IPV4
>         AssignedTo: shemminger@linux-foundation.org
>         ReportedBy: dmitriy.balakin@nicneiron.ru
>         Regression: No
>=20
>=20
> Created an attachment (id=3D40012)
>  --> (https://bugzilla.kernel.org/attachment.cgi?id=3D40012)
> Patch
>=20
> First, sorry for my bad english.=20
>=20
> The issue is that Linux-based OS sometimes can't make an tcp connecti=
on to some
> Windows servers with switched on buggy implementation of rfc1323, tha=
t
> described on this forum:
> http://www.network-builders.com/windows-tcp-timestamp-not-compliant-r=
fc-1323-a-t80898.html.
>=20
> Because some Windows hosts implementation of rfc1323 bases on randoml=
y
> generated TSval and sent first value of TSval as 0, the difference of=
 recent
> and new TSval sometimes has been affected by a sign magic issue and t=
he PAWS
> mechanism has been triggered. Anyway, the rfc1323 has discribes the c=
ondition
> of PAWS as "0 < (t - s) < 2**31", that has been right implementation =
in current
> linux kernel, but incompatible with Windows bug.
>=20
> For example, the one of affected to this issue Windows host is behind
> relay.n-l-e.ru:80
>=20
> I think that my small patch makes the kernel more compatible with thi=
s windows
> bug.
>=20
> -

I have no problem connecting my linux client to relay.n-l-e.ru:80

Could you elaborate please ?

18:13:12.444250 IP 10.150.51.215.51781 > 212.176.201.162.80: Flags [S],
seq 665972386, win 5840, options [mss 1460,sackOK,TS val 1746885 ecr
0,nop,wscale 7], length 0
18:13:12.473912 IP 212.176.201.162.80 > 10.150.51.215.51781: Flags [S.]=
,
seq 190215045, ack 665972387, win 5792, options [mss 1460,sackOK,TS val
730697107 ecr 1746885,nop,wscale 0], length 0
18:13:12.473976 IP 10.150.51.215.51781 > 212.176.201.162.80: Flags [.],
ack 1, win 46, options [nop,nop,TS val 1746888 ecr 730697107], length 0
18:13:14.984153 IP 10.150.51.215.51781 > 212.176.201.162.80: Flags [P.]=
,
seq 1:8, ack 1, win 46, options [nop,nop,TS val 1747139 ecr 730697107],
length 7
18:13:15.013901 IP 212.176.201.162.80 > 10.150.51.215.51781: Flags [.],
ack 8, win 5792, options [nop,nop,TS val 730697360 ecr 1747139], length
0
18:13:15.377879 IP 10.150.51.215.51781 > 212.176.201.162.80: Flags [P.]=
,
seq 8:10, ack 1, win 46, options [nop,nop,TS val 1747178 ecr 730697360]=
,
length 2
18:13:15.403900 IP 212.176.201.162.80 > 10.150.51.215.51781: Flags [.],
ack 10, win 5792, options [nop,nop,TS val 730697399 ecr 1747178], lengt=
h
0
18:13:15.461384 IP 212.176.201.162.80 > 10.150.51.215.51781: Flags [P.]=
,
seq 1:159, ack 10, win 5792, options [nop,nop,TS val 730697405 ecr
1747178], length 158
18:13:15.461429 IP 10.150.51.215.51781 > 212.176.201.162.80: Flags [.],
ack 159, win 54, options [nop,nop,TS val 1747186 ecr 730697405], length
0
18:13:15.461448 IP 212.176.201.162.80 > 10.150.51.215.51781: Flags [F.]=
,
seq 159, ack 10, win 5792, options [nop,nop,TS val 730697405 ecr
1747178], length 0
18:13:15.461607 IP 10.150.51.215.51781 > 212.176.201.162.80: Flags [F.]=
,
seq 10, ack 160, win 54, options [nop,nop,TS val 1747186 ecr 730697405]=
,
length 0
18:13:15.533846 IP 212.176.201.162.80 > 10.150.51.215.51781: Flags [.],
ack 11, win 5792, options [nop,nop,TS val 730697412 ecr 1747186], lengt=
h
0


