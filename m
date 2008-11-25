From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 10/10] tcp: handle shift/merge of cloned skbs too
Date: Mon, 24 Nov 2008 21:32:02 -0800 (PST)
Message-ID: <20081124.213202.09724181.davem@davemloft.net>
References: <1227536527-29713-9-git-send-email-ilpo.jarvinen@helsinki.fi>
	<1227536527-29713-10-git-send-email-ilpo.jarvinen@helsinki.fi>
	<1227536527-29713-11-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48005
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750890AbYKYFcD convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 25 Nov 2008 00:32:03 -0500
In-Reply-To: <1227536527-29713-11-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: "Ilpo J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Date: Mon, 24 Nov 2008 16:22:07 +0200

> This caused me to get repeatably:
>=20
>   tcpdump: pcap_loop: recvfrom: Bad address
>=20
> Happens occassionally when I tcpdump my for-looped test xfers:
>   while [ : ]; do echo -n "$(date '+%s.%N') "; ./sendfile; sleep 20; =
done
>=20
> Rest of the relevant commands:
>   ethtool -K eth0 tso off
>   tc qdisc add dev eth0 root netem drop 4%
>   tcpdump -n -s0 -i eth0 -w sacklog.all

I'm applying this in any event.

What could be happening is some bad clone handling
elsewhere (AF_PACKET, for example) and thus for some
reason libpcap reads stale data then performs a packet
read using incorrect lengths and this leads to reading
past the end of it's user buffer and we -EFAULT.

Just capturing the -EFAULT'ing call arguments with strace
would be enough to give some deeper clues.  Do you have
that?
