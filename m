From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH net-next-2.6] net: Fix some corner cases in dev_can_checksum()
Date: Tue, 26 Oct 2010 14:29:19 +0100
Message-ID: <20101026132918.GG15074@solarflare.com>
References: <1287618974-4714-1-git-send-email-jesse@nicira.com> <1287618974-4714-5-git-send-email-jesse@nicira.com> <1287675008.2235.8.camel@achroite.uk.solarflarecom.com> <AANLkTi=6erj4L7mwH4j1h+urPrc2PQu2xg7xTHkiM0A5@mail.gmail.com> <1287756739.2316.11.camel@achroite.uk.solarflarecom.com> <AANLkTi=PiB_oCvaFzQpUNhgV8qsn9d-jy_ejGdbOTzQe@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Jesse Gross <jesse@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:52821 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751529Ab0JZN3W (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Oct 2010 09:29:22 -0400
Content-Disposition: inline
In-Reply-To: <AANLkTi=PiB_oCvaFzQpUNhgV8qsn9d-jy_ejGdbOTzQe@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jesse Gross wrote:
> On Fri, Oct 22, 2010 at 7:12 AM, Ben Hutchings
> <bhutchings@solarflare.com> wrote:
> > dev_can_checksum() incorrectly returns true in these cases:
> >
> > 1. The skb has both out-of-band and in-band VLAN tags and the devic=
e
> > =A0 supports checksum offload for the encapsulated protocol but onl=
y with
> > =A0 one layer of encapsulation.
> > 2. The skb has a VLAN tag and the device supports generic checksumm=
ing
> > =A0 but not in conjunction with VLAN encapsulation.
> >
> > Rearrange the VLAN tag checks to avoid these.
> >
> > Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
>=20
> If we assume that cards cannot handle offloading for double tagged
> packets, which is obviously the most conservative approach, we
> probably also need to change the checks for TSO/SG.  There's no issue
> with extracting the protocol from the right header but we might assum=
e
> that the card can handle double tag offloading when it can't.  For
> both TSO/SG we check if there is either an in-band tag or out-of-band
> tag and use dev->vlan_features if that is the case.  Maybe we need to
> handle it in software if it is double tagged.

That's something to check.

> On the other hand, I don't know whether it's true that cards can't
> handle offloading for packets tagged in both manners.  I suppose that
> it depends on where the offloading and tagging are in the pipeline.
> For example, when it comes to SG I doubt that the cards care about
> vlan tags much at all.

I do know that current Solarflare controllers can parse two VLAN tags
and generate/validate TCP/IP-style checksums after them.  We could add
vlan2_features which would be copied to a VLAN sub-device's
vlan_features, but then what happens when people want to handle triple
VLAN encapsulation?

Ben.

--=20
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
