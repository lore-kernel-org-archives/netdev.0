From: Timo Teras <timo.teras@iki.fi>
Subject: Re: [PATCH v2 net-next] arp: flush arp cache on IFF_NOARP change
Date: Tue, 21 May 2013 21:29:30 +0300
Message-ID: <20130521212930.01efd34e@vostro>
References: <20130520.134633.448574202175922639.davem@davemloft.net>
	<1369131824-6318-1-git-send-email-timo.teras@iki.fi>
	<1369153519.2615.3.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<kaber@trash.net>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f51.google.com ([74.125.83.51]:37606 "EHLO
	mail-ee0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755265Ab3EUS15 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 May 2013 14:27:57 -0400
Received: by mail-ee0-f51.google.com with SMTP id e51so606104eek.24
        for <netdev@vger.kernel.org>; Tue, 21 May 2013 11:27:56 -0700 (PDT)
In-Reply-To: <1369153519.2615.3.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 21 May 2013 17:25:19 +0100
Ben Hutchings <bhutchings@solarflare.com> wrote:

> On Tue, 2013-05-21 at 13:23 +0300, Timo Ter=C3=A4s wrote:
> > IFF_NOARP affects what kind of neighbor entries are created
> > (nud NOARP or nud INCOMPLETE). If the flag changes, flush the arp
> > cache to refresh all entries.
> >=20
> > Signed-off-by: Timo Ter=C3=A4s <timo.teras@iki.fi>
> > ---
> > > This patch makes no sense at all.
> > >=20
> > > The state bit in ->priv_flags is a boolean stating whether the
> > > notified should do something or not.
> > >=20
> > > But you're setting it to match what IFF_NOARP is.
> > >
> > > You should set it any time IFF_NOARP _changes_, and then clear
> > > the bit when the notifier clears the neighbour entries.
> >=20
> > IFF_NOARP_CHANGED is set according to "changes =3D dev->flags ^
> > old_flags;" which reflect the change. But I agree that the clearing
> > out bit was misplaced. This is especially true as it seems
> > NETDEV_CHANGE can be notified from another place too.
> [...]
>=20
> None of the other persistent flags have a transient flag for changes;
> why should IFF_NOARP?  Why not cache the IFF_NOARP state in the
> in_device and then compare and update that in arp_netdev_event().

This was the earlier suggestion I got, so I followed that. NOARP flag
is also used in IPv6 side (quick look would indicate that ndisc code
needs similar fix), so it would be useful to have this generally
available.

Would it be worthwhile to consider adding "flags_changed" to struct
net_device or some other mechanism add this info about all flags?
