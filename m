From: Lucian Adrian Grijincu <lgrijincu@ixiacom.com>
Subject: Re: [PATCH 1/2] udp: cleanup __udp4_lib_mcast_deliver
Date: Fri, 6 Nov 2009 16:04:21 +0200
Message-ID: <200911061604.21465.lgrijincu@ixiacom.com>
References: <200911052033.21964.lgrijincu@ixiacom.com> <20091106.004215.114490979.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, opurdila@ixiacom.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ixro-out-rtc.ixiacom.com ([92.87.192.98]:16781 "EHLO
	ixro-ex1.ixiacom.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754757AbZKFOET convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Nov 2009 09:04:19 -0500
In-Reply-To: <20091106.004215.114490979.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=CEn data de Vin 06 Noi 2009 10:42:15 David Miller a scris:
> Getting rid of the useless return value is fine, but the
> new do{}while() loop et al. is less readable to me.

It's not new.
I just moved it:
previously:
	if(cond) {
		do {}
		 while()
	} else {return}

now:
	if (!cond)
		return;
	do {}
	while {}

Also this moves a consume_skb() from a path protected by spin locks.

As far as I understand it, the spin locks protect the hslot, and freein=
g the=20
skb does not walk/change or interact with the hslot in any way.

--=20
Lucian
