From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [PATCH] [TCP] Sysctl: document tcp_max_ssthresh (Limited	Slow-Start)
Date: Fri, 18 May 2007 12:39:17 -0700
Message-ID: <464E00E5.5050801@hp.com>
References: <Pine.LNX.4.64.0705181926570.22402@kivilampi-30.cs.helsinki.fi> <464DE584.7030008@ev-en.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?ISO-8859-1?Q?Ilpo_J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>,
	David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>
To: Baruch Even <baruch@ev-en.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from palrel11.hp.com ([156.153.255.246]:46164 "EHLO palrel11.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752893AbXERTkD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 May 2007 15:40:03 -0400
In-Reply-To: <464DE584.7030008@ev-en.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Baruch Even wrote:
> Ilpo J=E4rvinen wrote:
>=20
>>Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
>>---
>> Documentation/networking/ip-sysctl.txt |   13 +++++++++++++
>> 1 files changed, 13 insertions(+), 0 deletions(-)
>>
>>diff --git a/Documentation/networking/ip-sysctl.txt b/Documentation/n=
etworking/ip-sysctl.txt
>>index ce16e6a..44ba8d4 100644
>>--- a/Documentation/networking/ip-sysctl.txt
>>+++ b/Documentation/networking/ip-sysctl.txt
>>@@ -239,6 +239,19 @@ tcp_max_orphans - INTEGER
>> 	more aggressively. Let me to remind again: each orphan eats
>> 	up to ~64K of unswappable memory.
>>=20
>>+tcp_max_ssthresh - INTEGER
>>+	Limited Slow-Start for TCP with Large Congestion Windows defined in
>>+	RFC3742. Limited slow-start is a mechanism to limit grow of the
>=20
>=20
> s/grow/growth/
>=20
>=20
>>+	congestion window on the region where congestion window is larger t=
han
>>+	tcp_max_ssthresh. A TCP connection with a large congestion window c=
ould
>>+	have its congestion window increased by thousand (or even more)
>>+	segments per RTT by the traditional slow-start procedure which migh=
t be
>>+	counter-productive to TCP performance when packet losses start to
>>+	occur. With limited slow-start TCP increments congestion window at
>>+	most tcp_max_ssthresh/2 segments per RTT when the congestion window=
 is
>=20
>=20
> I'm not a native English speaker but "at most" sounds a bit awkward t=
o
> me, maybe change it to "by no more than". But I'm sure someone can fi=
nd
> a better phrasing.

It could be "by at most" or "by no more than" but indeed it should not =
just be=20
"at most."

Also, it should be "With limited slow-start TCP increments the congesti=
on=20
window..."   Combining with other nits yeilds:

Limited Slow-Start for TCP with Large Congestion Windows is defined in =
RFC3742.=20
  Limited slow-start is a mechanism to limit growth of the congestion w=
indow=20
when the congestion window is larger than tcp_max_ssthresh.  A TCP conn=
ection=20
with a large congestion window could have its congestion window increas=
ed by=20
thousands of segments (or more) per RTT via the traditional slow-start=20
procedures. This might degrade TCP performance when packet losses start=
 to=20
occur.  With limited slow-start, TCP increments the congestion window b=
y at most=20
tcp_max_ssthresh/2 segments per RTT when the congestion window is is ab=
ove=20
tcp_max_ssthresh.

rick jones

as an asside, "tcp_max_ssthresh" sounds like the maximum value ssthresh=
 can=20
take-on.  is that correct, or is this more of a "once ssthresh is above=
 this,=20
behave in this new way?"  If that is the case, while the horse has prob=
ably left=20
the barn, perhaps another name would be better?

>=20
> Baruch
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

