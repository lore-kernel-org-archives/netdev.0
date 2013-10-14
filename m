From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: [RFC] ipv6: always join solicited-node address
Date: Mon, 14 Oct 2013 09:09:59 +0200
Message-ID: <87fvs4s4zc.fsf@nemi.mork.no>
References: <1381685064-24805-1-git-send-email-bjorn@mork.no>
	<20131014005508.GE14021@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:54940 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751259Ab3JNHKY convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Oct 2013 03:10:24 -0400
Received: from nemi.mork.no (ip6-localhost [IPv6:::1])
	by canardo.mork.no (8.14.4/8.14.4) with ESMTP id r9E7AF6l009960
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Mon, 14 Oct 2013 09:10:15 +0200
Received: from bjorn by nemi.mork.no with local (Exim 4.80)
	(envelope-from <bjorn@mork.no>)
	id 1VVcHv-0004KU-8D
	for netdev@vger.kernel.org; Mon, 14 Oct 2013 09:09:59 +0200
In-Reply-To: <20131014005508.GE14021@order.stressinduktion.org> (Hannes
	Frederic Sowa's message of "Mon, 14 Oct 2013 02:55:08 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hannes Frederic Sowa <hannes@stressinduktion.org> writes:

> IFF_NOARP seems to be a bit messed up in ipv6. Your patch seems fine =
to
> me but I would add protection to the ndisc_rcv and sending routines t=
o
> do nothing if IFF_NOARP is set for that interface.

That's what I thought.  So for my problem, this will not really change
much.

> So it would be possible that you could resolve this issue by just iss=
uing
> an "ip link set arp on dev <interface>" and won't have hassle with ra=
cing
> interface initialization.

Yes, but that would also make the IP layer try to resolve IP to link
layer addressess both for IPv4 and IPv6, which just won't work. At leas=
t
not for IPv4, where there just is no way to transport an ARP to the
modem.  And I assume it may fail for IPv6 too on any sane device.

> Is this a specific bug of the modem you are using or are all devices
> powered by this driver like this?

Unfortunately I have no IPv6 enabled SIM myself, so I have no
information about other devices.  This report was based on user
feedback.

I assume the bug is specific to this firmware implementation, probably
extending to all similar devices from the same vendor.  But it could be
more common than that.  The fact that the bug is there indicates that
this works just fine in Windows.

Yes, I realize that I am in ugly-hack-to-workaround-firmware-issues lan=
d
again... But it sure would be nice to have some way for a driver to
indicate that L2 neighbour tables are meaningless, but that any incomin=
g
requests should still be answered.


Bj=C3=B8rn
