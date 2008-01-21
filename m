From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: questions on NAPI processing latency and dropped network packets
Date: Mon, 21 Jan 2008 22:31:09 +0100
Message-ID: <47950F1D.4010508@cosmosbay.com>
References: <478654C3.60806@nortel.com> <4794F848.9020402@nortel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Chris Friesen <cfriesen@nortel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([86.65.150.130]:44135 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751668AbYAUVbW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jan 2008 16:31:22 -0500
In-Reply-To: <4794F848.9020402@nortel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Chris Friesen a =E9crit :
> I've done some further digging, and it appears that one of the proble=
ms=20
> we may be facing is very high instantaneous traffic rates.
>=20
> Instrumentation showed up to 222K packets/sec for short periods (at=20
> least 1.1 ms, possibly longer), although the long-term average is dow=
n=20
> around 14-16K packets/sec.

Instrumentation done where exactly ?

tcpdump on the host will lie, since timestamps are probably going to be=
 host=20
timestamps, giving the time of RX dequeing, and not time of packets arr=
ival=20
given by NIC.

>=20
> If I bump the rx ring size up to 4096, we can handle all the packets =
and=20
> we still have 44% idle on cpu0 and 27% idle on cpu1.
>=20
> Is there anything else we can do to minimize the latency of network=20
> packet processing and avoid having to crank the rx ring size up so hi=
gh?
>=20


You have some tasks that disable softirqs too long. Sometimes, bumping =
RX ring=20
size is OK (but you will still have delays), sometimes it is not an opt=
ion,=20
since 4096 is the limit on current hardware.

