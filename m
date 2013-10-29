From: Nathan Hintz <nlhintz@hotmail.com>
Subject: Re: [PATCH] bgmac: don't update slot on skb alloc/dma mapping error
Date: Tue, 29 Oct 2013 01:22:55 -0700
Message-ID: <BLU0-SMTP200803D333FF3A2F15AB82DAC090@phx.gbl>
References: <BLU0-SMTP119F7A71B34291D1CC2486BAC090@phx.gbl>
	<CACna6rzxt2QMtLfD84pw7EtYqg1Qva4ah83hVQOKpeKy72bd5w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Network Development <netdev@vger.kernel.org>
To: =?UTF-8?B?UmFmYcWCIE1pxYJlY2tp?= <zajec5@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from blu0-omc1-s23.blu0.hotmail.com ([65.55.116.34]:33060 "EHLO
	blu0-omc1-s23.blu0.hotmail.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753298Ab3J2IW6 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Oct 2013 04:22:58 -0400
In-Reply-To: <CACna6rzxt2QMtLfD84pw7EtYqg1Qva4ah83hVQOKpeKy72bd5w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 29 Oct 2013 07:52:58 +0100
Rafa=C5=82 Mi=C5=82ecki <zajec5@gmail.com> wrote:

> 2013/10/29 Nathan Hintz <nlhintz@hotmail.com>:
> > Don't update the slot in "bgmac_dma_rx_skb_for_slot" unless both th=
e
> > skb alloc and dma mapping are successful; and free the newly alloca=
ted
> > skb if a dma mapping error occurs.  This will prevent an skb leak u=
pon
> > returning when an error occurs.
>=20
> In case of bgmac_dma_rx_skb_for_slot failure we're giving up anyway
> (and freeing everything), but with your patch code is simpler to
> understand, so I'm OK with that.
>=20
> Acked-by: Rafa=C5=82 Mi=C5=82ecki <zajec5@gmail.com>
>=20

I might be misunderstanding; but it in the case of failure, it appeared=
 to me
that the currently received packet was dropped and the old skb would co=
ntinue
to be assigned to the slot and would be used to receive future packets =
(this
would continue until bgmac_dma_rx_skb_for_slot was successful).

--=20
Nathan
