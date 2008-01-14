From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: Why are network counters only updated once a second?
Date: Mon, 14 Jan 2008 21:45:33 +0100
Message-ID: <478BC9ED.2000204@cosmosbay.com>
References: <478BC662.6030004@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>
To: Mark Seger <Mark.Seger@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([86.65.150.130]:41690 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750861AbYANUpt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Jan 2008 15:45:49 -0500
In-Reply-To: <478BC662.6030004@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mark Seger a =E9crit :
> I had mentioned this in my previous post but perhaps it might get mor=
e=20
> attention all by itself.  I can't say for sure when this changed, but=
=20
> for the longest time network counters were only updated once every=20
> 0.9765 seconds and unless you used a tools like collectl that could=20
> monitor at fractional intervals, your traffic was under-reported AND=20
> you'd get periodic spikes of double the actual rate.  See=20
> http://collectl.sourceforge.net/NetworkStats.html for a more complete=
=20
> explanation.
>=20
> Eventually the frequency became better aligned at a 1 second interval=
=20
> because now the number look better, but the problem I see is that whe=
n=20
> the sampling interval is very close to the monitoring interval you st=
ill=20
> get periodic incorrect data.  Furthermore, you now need to know which=
=20
> way the counters are updated before you pick a sampling interval!  Bu=
t=20
> the real point is if anyone ever wants to do finer grained monitoring=
,=20
> say every 1/2 or even tenth of a second, they can't because the count=
ers=20
> won't change between samples.  Has this ever been discussed before?
>=20

Yes it was discussed before. Some devices perform counters updates dire=
ctly at=20
the NIC level, and one in a while a transfert of counters is done to th=
e host.

This is supposed to be better, especially on SMP.

Maybe you need to setup accounting rules with iptables, so that you can=
=20
perform counter sampling at whatever rate you want ?

