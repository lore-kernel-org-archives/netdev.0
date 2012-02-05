From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv4: reset flowi parameters on route connect
Date: Sat, 04 Feb 2012 19:30:23 -0500 (EST)
Message-ID: <20120204.193023.2287808303988988750.davem@davemloft.net>
References: <1328396686-15430-1-git-send-email-ja@ssi.bg>
	<1328398416.2731.52.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: ja@ssi.bg, netdev@vger.kernel.org, Yurij.Plotnikov@oktetlabs.ru
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:37120 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753502Ab2BEAao convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Feb 2012 19:30:44 -0500
In-Reply-To: <1328398416.2731.52.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sun, 05 Feb 2012 00:33:36 +0100

> Le dimanche 05 f=E9vrier 2012 =E0 01:04 +0200, Julian Anastasov a =E9=
crit :
>> 	Eric Dumazet found that commit 813b3b5db83
>> (ipv4: Use caller's on-stack flowi as-is in output
>> route lookups.) that comes in 3.0 added a regression.
>> The problem appears to be that resulting flowi4_oif is
>> used incorrectly as input parameter to some routing lookups.
>> The result is that when connecting to local port without
>> listener if the IP address that is used is not on a loopback
>> interface we incorrectly assign RTN_UNICAST to the output
>> route because no route is matched by oif=3Dlo. The RST packet
>> can not be sent immediately by tcp_v4_send_reset because
>> it expects RTN_LOCAL.
>>=20
>> 	So, change ip_route_connect and ip_route_newports to
>> update the flowi4 fields that are input parameters because
>> we do not want unnecessary binding to oif.
>>=20
>> 	To make it clear what are the input parameters that
>> can be modified during lookup and to show which fields of
>> floiw4 are reused add a new function to update the flowi4
>> structure: flowi4_update_output.
>>=20
>> Thanks to Yurij M. Plotnikov for providing a bug report including a
>> program to reproduce the problem.
>>=20
>> Thanks to Eric Dumazet for tracking the problem down to
>> tcp_v4_send_reset and providing initial fix.
>>=20
>> Reported-by: Yurij M. Plotnikov <Yurij.Plotnikov@oktetlabs.ru>
>> Signed-off-by: Julian Anastasov <ja@ssi.bg>
=2E..
> Acked-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied, thanks everyone.
