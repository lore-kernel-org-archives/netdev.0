From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bgmac: don't update slot on skb alloc/dma mapping error
Date: Tue, 29 Oct 2013 15:39:57 -0400 (EDT)
Message-ID: <20131029.153957.1658989244969068757.davem@davemloft.net>
References: <BLU0-SMTP119F7A71B34291D1CC2486BAC090@phx.gbl>
	<CACna6rzxt2QMtLfD84pw7EtYqg1Qva4ah83hVQOKpeKy72bd5w@mail.gmail.com>
	<BLU0-SMTP200803D333FF3A2F15AB82DAC090@phx.gbl>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=euc-kr
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: zajec5@gmail.com, netdev@vger.kernel.org
To: nlhintz@hotmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47965 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751238Ab3J2Tj6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Oct 2013 15:39:58 -0400
In-Reply-To: <BLU0-SMTP200803D333FF3A2F15AB82DAC090@phx.gbl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Nathan Hintz <nlhintz@hotmail.com>
Date: Tue, 29 Oct 2013 01:22:55 -0700

> On Tue, 29 Oct 2013 07:52:58 +0100
> Rafa=A9=A9 Mi=A9=A9ecki <zajec5@gmail.com> wrote:
>=20
>> 2013/10/29 Nathan Hintz <nlhintz@hotmail.com>:
>> > Don't update the slot in "bgmac_dma_rx_skb_for_slot" unless both t=
he
>> > skb alloc and dma mapping are successful; and free the newly alloc=
ated
>> > skb if a dma mapping error occurs.  This will prevent an skb leak =
upon
>> > returning when an error occurs.
>>=20
>> In case of bgmac_dma_rx_skb_for_slot failure we're giving up anyway
>> (and freeing everything), but with your patch code is simpler to
>> understand, so I'm OK with that.
>>=20
>> Acked-by: Rafa=A9=A9 Mi=A9=A9ecki <zajec5@gmail.com>
>>=20
>=20
> I might be misunderstanding; but it in the case of failure, it appear=
ed to me
> that the currently received packet was dropped and the old skb would =
continue
> to be assigned to the slot and would be used to receive future packet=
s (this
> would continue until bgmac_dma_rx_skb_for_slot was successful).

That's exactly the wanted, and most desirable, behavior for any network
driver.

If you can't allocate a new SKB, reuse the old one, because the worst
thing you can do is prioritize packet reception over making sure the
device doesn't end up with no RX slots to DMA into.
