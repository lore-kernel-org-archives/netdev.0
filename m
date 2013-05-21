From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH v2 net-next] arp: flush arp cache on IFF_NOARP change
Date: Tue, 21 May 2013 17:25:19 +0100
Message-ID: <1369153519.2615.3.camel@bwh-desktop.uk.solarflarecom.com>
References: <20130520.134633.448574202175922639.davem@davemloft.net>
	 <1369131824-6318-1-git-send-email-timo.teras@iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<kaber@trash.net>
To: Timo =?ISO-8859-1?Q?Ter=E4s?= <timo.teras@iki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:23863 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751629Ab3EUQZY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 May 2013 12:25:24 -0400
In-Reply-To: <1369131824-6318-1-git-send-email-timo.teras@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-05-21 at 13:23 +0300, Timo Ter=C3=A4s wrote:
> IFF_NOARP affects what kind of neighbor entries are created
> (nud NOARP or nud INCOMPLETE). If the flag changes, flush the arp
> cache to refresh all entries.
>=20
> Signed-off-by: Timo Ter=C3=A4s <timo.teras@iki.fi>
> ---
> > This patch makes no sense at all.
> >=20
> > The state bit in ->priv_flags is a boolean stating whether the
> > notified should do something or not.
> >=20
> > But you're setting it to match what IFF_NOARP is.
> >
> > You should set it any time IFF_NOARP _changes_, and then clear
> > the bit when the notifier clears the neighbour entries.
>=20
> IFF_NOARP_CHANGED is set according to "changes =3D dev->flags ^ old_f=
lags;"
> which reflect the change. But I agree that the clearing out bit was
> misplaced. This is especially true as it seems NETDEV_CHANGE can be
> notified from another place too.
[...]

None of the other persistent flags have a transient flag for changes;
why should IFF_NOARP?  Why not cache the IFF_NOARP state in the
in_device and then compare and update that in arp_netdev_event().

Ben.

--=20
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
