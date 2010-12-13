From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Fw: [Bug 24842] New: Compatibility issue with uggly Windows
 RFC1323 implementation.
Date: Mon, 13 Dec 2010 23:31:02 +0100
Message-ID: <1292279462.2679.146.camel@edumazet-laptop>
References: <20101213085913.374c1072@nehalam>
	 <1292260479.2759.69.camel@edumazet-laptop>
	 <AANLkTikTgbKSNYHthic8P3bi9+ewN8fEBknnSK=tdTgU@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <shemminger@vyatta.com>, netdev@vger.kernel.org
To: =?UTF-8?Q?=D0=94=D0=BC=D0=B8=D1=82=D1=80=D0=B8=D0=B9_?=
	 =?UTF-8?Q?=D0=91=D0=B0=D0=BB=D0=B0=D0=BA=D0=B8=D0=BD?=
	<dmitriy.balakin@nicneiron.ru>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:46283 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750766Ab0LMWbI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Dec 2010 17:31:08 -0500
Received: by wwa36 with SMTP id 36so6850932wwa.1
        for <netdev@vger.kernel.org>; Mon, 13 Dec 2010 14:31:07 -0800 (PST)
In-Reply-To: <AANLkTikTgbKSNYHthic8P3bi9+ewN8fEBknnSK=tdTgU@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 13 d=C3=A9cembre 2010 =C3=A0 23:44 +0300, =D0=94=D0=BC=D0=B8=D1=
=82=D1=80=D0=B8=D0=B9 =D0=91=D0=B0=D0=BB=D0=B0=D0=BA=D0=B8=D0=BD a =C3=A9=
crit :
> 2010/12/13 Eric Dumazet <eric.dumazet@gmail.com>:
> > Le lundi 13 d=C3=A9cembre 2010 =C3=A0 08:59 -0800, Stephen Hemminge=
r a =C3=A9crit :
> >>
> >> Begin forwarded message:
> >>
> >> Date: Mon, 13 Dec 2010 14:29:58 GMT
> >> From: bugzilla-daemon@bugzilla.kernel.org
> >> To: shemminger@linux-foundation.org
> >> Subject: [Bug 24842] New: Compatibility issue with uggly Windows R=
=46C1323 implementation.
> >>
> >>
> >> https://bugzilla.kernel.org/show_bug.cgi?id=3D24842
> >>
> >>            Summary: Compatibility issue with uggly Windows RFC1323
> >>                     implementation.
> >>            Product: Networking
> >>            Version: 2.5
> >>     Kernel Version: All
> >>           Platform: All
> >>         OS/Version: Linux
> >>               Tree: Mainline
> >>             Status: NEW
> >>           Severity: normal
> >>           Priority: P1
> >>          Component: IPV4
> >>         AssignedTo: shemminger@linux-foundation.org
> >>         ReportedBy: dmitriy.balakin@nicneiron.ru
> >>         Regression: No
> >>
> >>
> >> Created an attachment (id=3D40012)
> >>  --> (https://bugzilla.kernel.org/attachment.cgi?id=3D40012)
> >> Patch
> >>
> >> First, sorry for my bad english.
> >>
> >> The issue is that Linux-based OS sometimes can't make an tcp conne=
ction to some
> >> Windows servers with switched on buggy implementation of rfc1323, =
that
> >> described on this forum:
> >> http://www.network-builders.com/windows-tcp-timestamp-not-complian=
t-rfc-1323-a-t80898.html.
> >>
> >> Because some Windows hosts implementation of rfc1323 bases on rand=
omly
> >> generated TSval and sent first value of TSval as 0, the difference=
 of recent
> >> and new TSval sometimes has been affected by a sign magic issue an=
d the PAWS
> >> mechanism has been triggered. Anyway, the rfc1323 has discribes th=
e condition
> >> of PAWS as "0 < (t - s) < 2**31", that has been right implementati=
on in current
> >> linux kernel, but incompatible with Windows bug.
> >>
> >> For example, the one of affected to this issue Windows host is beh=
ind
> >> relay.n-l-e.ru:80
> >>
> >> I think that my small patch makes the kernel more compatible with =
this windows
> >> bug.
> >>
> >> -
> >
> > I have no problem connecting my linux client to relay.n-l-e.ru:80
> >
> > Could you elaborate please ?
> >
> > 18:13:12.444250 IP 10.150.51.215.51781 > 212.176.201.162.80: Flags =
[S],
> > seq 665972386, win 5840, options [mss 1460,sackOK,TS val 1746885 ec=
r
> > 0,nop,wscale 7], length 0
> > 18:13:12.473912 IP 212.176.201.162.80 > 10.150.51.215.51781: Flags =
[S.],
> > seq 190215045, ack 665972387, win 5792, options [mss 1460,sackOK,TS=
 val
> > 730697107 ecr 1746885,nop,wscale 0], length 0
> > 18:13:12.473976 IP 10.150.51.215.51781 > 212.176.201.162.80: Flags =
[.],
> > ack 1, win 46, options [nop,nop,TS val 1746888 ecr 730697107], leng=
th 0
> > 18:13:14.984153 IP 10.150.51.215.51781 > 212.176.201.162.80: Flags =
[P.],
> > seq 1:8, ack 1, win 46, options [nop,nop,TS val 1747139 ecr 7306971=
07],
> > length 7
> > 18:13:15.013901 IP 212.176.201.162.80 > 10.150.51.215.51781: Flags =
[.],
> > ack 8, win 5792, options [nop,nop,TS val 730697360 ecr 1747139], le=
ngth
> > 0
> > 18:13:15.377879 IP 10.150.51.215.51781 > 212.176.201.162.80: Flags =
[P.],
> > seq 8:10, ack 1, win 46, options [nop,nop,TS val 1747178 ecr 730697=
360],
> > length 2
> > 18:13:15.403900 IP 212.176.201.162.80 > 10.150.51.215.51781: Flags =
[.],
> > ack 10, win 5792, options [nop,nop,TS val 730697399 ecr 1747178], l=
ength
> > 0
> > 18:13:15.461384 IP 212.176.201.162.80 > 10.150.51.215.51781: Flags =
[P.],
> > seq 1:159, ack 10, win 5792, options [nop,nop,TS val 730697405 ecr
> > 1747178], length 158
> > 18:13:15.461429 IP 10.150.51.215.51781 > 212.176.201.162.80: Flags =
[.],
> > ack 159, win 54, options [nop,nop,TS val 1747186 ecr 730697405], le=
ngth
> > 0
> > 18:13:15.461448 IP 212.176.201.162.80 > 10.150.51.215.51781: Flags =
[F.],
> > seq 159, ack 10, win 5792, options [nop,nop,TS val 730697405 ecr
> > 1747178], length 0
> > 18:13:15.461607 IP 10.150.51.215.51781 > 212.176.201.162.80: Flags =
[F.],
> > seq 10, ack 160, win 54, options [nop,nop,TS val 1747186 ecr 730697=
405],
> > length 0
> > 18:13:15.533846 IP 212.176.201.162.80 > 10.150.51.215.51781: Flags =
[.],
> > ack 11, win 5792, options [nop,nop,TS val 730697412 ecr 1747186], l=
ength
> > 0
> >
> >
> >
>=20
> Problems occur only when the remote side sets the TC val > 2147483647=
,
> ie when there is a sign:
>=20

You mean a windows machine with a big uptime ?
That must be quite rare indeed ;)

Anyway, we can not test values like suggested patch, or risk a problem
when wrap around occurs...

However, testing the special ts_recent=3D0 case would be possible (we
already did a change to accept a windows initiated connect to a linux
server and still activate tcp timestamps)

(commit fc1ad92dfc4e363a055 tcp: allow timestamps even if SYN packet ha=
s
tsval=3D0)

Something like following patch ?

Thanks


[PATCH net-next-2.6] tcp: relax tcp_paws_check()

Some windows versions have wrong RFC1323 implementations, with SYN and
SYNACKS messages containing zero tcp timestamps.

We relaxed in commit fc1ad92dfc4e363 the passive connection case
(Windows connects to a linux machine), but the reverse case (linux
connects to a Windows machine) has an analogue problem when tsvals from
windows machine are 'negative' (high order bit set) : PAWS triggers and
we drops incoming messages.

=46ix this by making zero ts_recent value special, allowing frame to be
processed.

Based on a report and initial patch from Dmitiy Balakin

Bugzilla reference : https://bugzilla.kernel.org/show_bug.cgi?id=3D2484=
2

Reported-by: dmitriy.balakin@nicneiron.ru
Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 include/net/tcp.h |    8 +++++++-
 1 file changed, 7 insertions(+), 1 deletion(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index 3f227ba..2ab6c9c 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -1038,7 +1038,13 @@ static inline int tcp_paws_check(const struct tc=
p_options_received *rx_opt,
 		return 1;
 	if (unlikely(get_seconds() >=3D rx_opt->ts_recent_stamp + TCP_PAWS_24=
DAYS))
 		return 1;
-
+	/*
+	 * Some OSes send SYN and SYNACK messages with tsval=3D0 tsecr=3D0,
+	 * then following tcp messages have valid values. Ignore 0 value,
+	 * or else 'negative' tsval might forbid us to accept their packets.
+	 */
+	if (!rx_opt->ts_recent)
+		return 1;
 	return 0;
 }
=20


