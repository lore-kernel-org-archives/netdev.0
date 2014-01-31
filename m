From: "Simon Schneider" <simon-schneider@gmx.net>
Subject: Aw: Re: Re: IPv4 / IPv6 over IPv4 IPsec tunnel: setting the DF bit
Date: Fri, 31 Jan 2014 09:27:27 +0100 (CET)
Message-ID: <trinity-ece5a90d-72c2-4db9-a1f7-8c9af2bbfa65-1391156847114@3capp-gmx-bs01>
References: <20140130142116.GD25336@order.stressinduktion.org>
 <trinity-a9289159-8d0c-4ad1-8586-e8987e008643-1391095583899@3capp-gmx-bs16>,
 <20140130155945.GF25336@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: "Hannes Frederic Sowa" <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.net ([212.227.15.18]:63664 "EHLO mout.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751404AbaAaI12 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 Jan 2014 03:27:28 -0500
Received: from 3capp-gmx-bs01.server.lan ([172.19.170.50]) by
 mrigmx.server.lan (mrigmx002) with ESMTP (Nemesis) id
 0M2amx-1VJFHO12eL-00sLed for <netdev@vger.kernel.org>; Fri, 31 Jan 2014
 09:27:27 +0100
In-Reply-To: <20140130155945.GF25336@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

<resending in text format>

Hi Hannes,
thanks.
=20
I think your IPv6 related statements are for a IPv6-over-IPv6 case.
=20
However, I'm especially after the IPv6-over-IPv4 case.
=20
In that case, you cannot copy the DF bit from the inner IPv6 packet.
=20
But you still have the option to set or not set the DF bit in the IPv4 =
outer packet.
=20
How is that decided?
=20
best regards, Simon
=C2=A0
=C2=A0

Gesendet:=C2=A0Donnerstag, 30. Januar 2014 um 16:59 Uhr
Von:=C2=A0"Hannes Frederic Sowa" <hannes@stressinduktion.org>
An:=C2=A0"Simon Schneider" <simon-schneider@gmx.net>
Cc:=C2=A0netdev@vger.kernel.org
Betreff:=C2=A0Re: Re: IPv4 / IPv6 over IPv4 IPsec tunnel: setting the D=
=46 bit
On Thu, Jan 30, 2014 at 04:26:24PM +0100, Simon Schneider wrote:
> Hi Hannes,
> thanks once again for the quick reply.
>
> Quickly checked the ip manpage. I'm clear about the case where pmtudi=
sc is in effect (default) - the DF bit must be TRUE in this case, for P=
MTUD to work.
>
> Not sure what you meant by:
>
> "but DF bit should get copied from inner packet up to tunnel header i=
n every
> case"
>
> Do you mean the nopmtudisc case?

Exactly. In nopmtudisc mode the flag is set based on the inner protocol=
s df
bit, default cleared. In pmtudisc mode the DF-flag is always set.

> Also, IPv6 must be different then - there's no DF bit to be copied.

If packet cannot traverse a router frag_needed is returned, tunnel
endpoint relays the icmp info to the original sender and it should upda=
te
its pmtu. There is no way to fragment the packet mid-path.

Also IPv6 tunnel endpoint do not fragment the tunnel packets while
encapsulating.

ipsec mode tunnel is allowed to fragment the packets while encapsulatio=
n.

> Could you please clarify?

Hope I did. ;)

Greetings,

Hannes
=C2=A0
