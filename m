From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH] NET : rt_check_expire() can take a long time, add a cond_resched()
Date: Sat, 17 Nov 2007 17:23:37 +0100
Message-ID: <473F1589.9080101@cosmosbay.com>
References: <473B69D5.2050805@cosmosbay.com> <p73r6isc6ev.fsf@bingen.suse.de>	<473C0297.5090004@cosmosbay.com> <p73fxz5auk5.fsf@bingen.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Andi Kleen <andi@firstfloor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([86.65.150.130]:54778 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752299AbXKQQXr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 17 Nov 2007 11:23:47 -0500
In-Reply-To: <p73fxz5auk5.fsf@bingen.suse.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andi Kleen a =E9crit :
> Eric Dumazet <dada1@cosmosbay.com> writes:
>=20
>> So it may sound unnecessary but in the rt_check_expire() case, with =
a
>> loop potentially doing XXX.XXX iterations, being able to bypass the
>> function call is a clear win (in my bench case, 25 ms instead of 88
>> ms). Impact on I-cache is irrelevant here as this rt_check_expires()
>=20
> Measuring what? And really milli-seconds? The number does not sound p=
lausible=20
> to me.

You know Andi, I have seen production servers that needed several secon=
ds to=20
perform the flush. When you have millions of entries on this table, can=
 you=20
imagine the number of memory transactions (including atomic ops) needed=
 to=20
flush them all ?

The 25.000.000 ns and 88.000.000 ns numbers where on an empty table, bu=
t large=20
(16 MB of memory)


