From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Strange CPU load when flushing route cache (kernel 2.6.31.6)
Date: Mon, 23 Nov 2009 14:25:21 +0100
Message-ID: <4B0A8D41.6010608@gmail.com>
References: <1258970332.29747.262.camel@jdb-workstation>	 <4B0A63FA.5000804@gmail.com> <1258979320.29747.270.camel@jdb-workstation>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux Kernel Network Hackers <netdev@vger.kernel.org>,
	Robert Olsson <robert@herjulf.net>
To: Jesper Dangaard Brouer <jdb@comx.dk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:46801 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751358AbZKWNZR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Nov 2009 08:25:17 -0500
In-Reply-To: <1258979320.29747.270.camel@jdb-workstation>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jesper Dangaard Brouer a =C3=A9crit :
> On Mon, 2009-11-23 at 11:29 +0100, Eric Dumazet wrote:

>> Sure, after a flush, we have to rebuild the cache, so extra work is =
expected.
>=20
> But the old 2.6.25.7 do NOT show this behavior... That is the real
> issue...

Previous kernels were crashing, because flush was immediate and not def=
erred
as today.

During flush, we were dropping enormous amounts of packets.

Now, its possible to have setups with equilibrium and no packet loss,
because we smoothtly invalidate cache entries.


> I did the cache flushing due to some historical issues, that I think =
you
> did a fix for... Guess I can drop the flushing and see if the garbage
> collection can keep up...

Yes it can. Unless your route cache settings are not optimal.

>=20
>> Do you run a 2G/2G User/Kernel split kernel ?
>=20
> Not sure, how do I check?

grep LowTotal /proc/meminfo

or

dmesg | grep LOWMEM
913MB LOWMEM available.   (standard 3G/1G User/Kernel split)


