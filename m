From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [RFC] ipv6: always join solicited-node address
Date: Mon, 14 Oct 2013 17:56:10 +0200
Message-ID: <20131014155610.GA20327@order.stressinduktion.org>
References: <1381685064-24805-1-git-send-email-bjorn@mork.no> <20131014005508.GE14021@order.stressinduktion.org> <87fvs4s4zc.fsf@nemi.mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: =?utf-8?B?QmrDuHJu?= Mork <bjorn@mork.no>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:33539 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750814Ab3JNP4L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Oct 2013 11:56:11 -0400
Content-Disposition: inline
In-Reply-To: <87fvs4s4zc.fsf@nemi.mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 14, 2013 at 09:09:59AM +0200, Bj=C3=B8rn Mork wrote:
> Yes, but that would also make the IP layer try to resolve IP to link
> layer addressess both for IPv4 and IPv6, which just won't work. At le=
ast
> not for IPv4, where there just is no way to transport an ARP to the
> modem.  And I assume it may fail for IPv6 too on any sane device.

I don't think that clearing the IFF_NOARP flag would kill connectivity
for either IPv4 or IPv6. It may compromise security for IPv6 though
(no idea how the telco network behind the modem looks like).

> > Is this a specific bug of the modem you are using or are all device=
s
> > powered by this driver like this?
>=20
> Unfortunately I have no IPv6 enabled SIM myself, so I have no
> information about other devices.  This report was based on user
> feedback.
>=20
> I assume the bug is specific to this firmware implementation, probabl=
y
> extending to all similar devices from the same vendor.  But it could =
be
> more common than that.  The fact that the bug is there indicates that
> this works just fine in Windows.
>=20
> Yes, I realize that I am in ugly-hack-to-workaround-firmware-issues l=
and
> again... But it sure would be nice to have some way for a driver to
> indicate that L2 neighbour tables are meaningless, but that any incom=
ing
> requests should still be answered.

L2 neighbour tables are resolved on demand and won't be queried for the
link you are talking about (at least for IPv6, but I assume IPv4, too).

A new flag should have clear semantics then:

* split IFF_NOARP to IFF_NOARP and IFF_NONDISC
* split IFF_NOARP to IFF_NOLLRESOLV_RESPONSE and IFF_NOLLRESOLV_MODIFY
  (each one flag which is applicable for both IPv4 and IPv6)

I tend to lean towards the last alternative but still wonder if this is
just overhead for this one buggy device.

Greetings,

  Hannes
