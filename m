From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [RFC] ipv6: always join solicited-node address
Date: Mon, 14 Oct 2013 02:55:08 +0200
Message-ID: <20131014005508.GE14021@order.stressinduktion.org>
References: <1381685064-24805-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: =?utf-8?B?QmrDuHJu?= Mork <bjorn@mork.no>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:60483 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755399Ab3JNAzK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Oct 2013 20:55:10 -0400
Content-Disposition: inline
In-Reply-To: <1381685064-24805-1-git-send-email-bjorn@mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Oct 13, 2013 at 07:24:24PM +0200, Bj=C3=B8rn Mork wrote:
> RFC 4861 section 7.2.1 "Interface Initialization" says:
>=20
>    When a multicast-capable interface becomes enabled, the node MUST
>    join the all-nodes multicast address on that interface, as well as
>    the solicited-node multicast address corresponding to each of the =
IP
>    addresses assigned to the interface.
>=20
> The current dependency on IFF_NOARP seems unwarranted. We need to
> listen on the solicited-node address whether or not we intend to
> initiate Neigbour Discovery ourselves.
>=20
> This fixes a bug where Linux fails to respond to received Neigbour
> Solicitations on multicast capable links when IFF_NOARP is set.
>=20
> Signed-off-by: Bj=C3=B8rn Mork <bjorn@mork.no>
> ---
> I am not at all sure about this... Comments are appreciated.
>=20
> The observed problem is a MBIM mobile broadband modem sending NS
> to the host.  MBIM is a point-to-point USB protocol which does not
> have any L2 headers at all.  It can only transport IPv4 or IPv6
> packets.  So for IPv4 there is no question at all:  ARP just
> cannot be transported. The driver emulates an ethernet interface,
> setting IFF_NOARP to make sure the upper layers doesn't attempt
> to resolve the neighbours non-existing L2 addresses.
>=20
> But then there is this modem which sends IPv6 Neigbour
> Solicitations to the host over the MBIM transport. The link
> layer addresses are meaningless, but it seems the modem still
> expects an answer.  Which we will not currently provide, because
> the NS is addressed to a solicited-node address we don't listen
> to.
>=20
> So this patch seems like a quick-fix to that problem.  But it does
> change the semantics of IFF_NOARP, making us reply to NS even if
> this flag is set.  Which probably is wrong?

IFF_NOARP seems to be a bit messed up in ipv6. Your patch seems fine to
me but I would add protection to the ndisc_rcv and sending routines to
do nothing if IFF_NOARP is set for that interface.

So it would be possible that you could resolve this issue by just issui=
ng
an "ip link set arp on dev <interface>" and won't have hassle with raci=
ng
interface initialization.

Is this a specific bug of the modem you are using or are all devices
powered by this driver like this?

Greetings,

  Hannes
