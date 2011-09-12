From: David Lamparter <equinox@diac24.net>
Subject: Re: Using gretap to tunnel layer 2 traffic
Date: Mon, 12 Sep 2011 14:52:50 +0200
Message-ID: <20110912125250.GA3020447@jupiter.n2.diac24.net>
References: <1315589104.22676.YahooMailNeo@web45104.mail.sp1.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: John H <uothrawn@yahoo.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from spaceboyz.net ([87.106.131.203]:46380 "EHLO spaceboyz.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754037Ab1ILMwz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 12 Sep 2011 08:52:55 -0400
Content-Disposition: inline
In-Reply-To: <1315589104.22676.YahooMailNeo@web45104.mail.sp1.yahoo.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 09, 2011 at 10:25:04AM -0700, John H wrote:
> [...]                         All VLANs and physical devices have MTU=
s of=20
> 1500.=C2=A0 The gretap device has a resultant MTU of 1462, thereby ca=
using the=20
> bridge device to have an MTU of 1462.
> [...]
> The real question is, however, why is any client able to send a singl=
e ICMP
> packet with size 1478 bytes when one of the hops along the way only=20
> supports 1462 bytes per its MTU? Shouldn't this have been negotiated=20
> beforehand?

No.

An Ethernet segment needs a single, unbroken, identical MTU at all of
its (packet-sending) participants. Your configuration is invalid; there
is no Ethernet-builtin mechanism to negotiate MTU.

You need to set all devices, hosts and possibly switches to the same MT=
U
value. (A switch with its default of 1500 isn't a problem as long as it
does not generate packets that large.) A way to do that is by DHCP,
which has a MTU option; that option is however not honoured by all
clients.

Alternatively, you need to change your gretap/bridge MTU to 1500, but
you'll somehow need to make gretap aware of the underlying
fragmentation support, from whereever it may come.

Alter-alternatively, you can use a layer 3 (IP/IPv6) router. IP, unlike
Ethernet, is designed to cope with varying MTUs...


-David
