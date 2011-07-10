From: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
Subject: Re: [PATCH] natsemi: silence dma-debug warnings
Date: Sun, 10 Jul 2011 11:18:22 +0900 (JST)
Message-ID: <20110710.111822.1898388363586143047.fujita.tomonori@lab.ntt.co.jp>
References: <CAJfuBxxs=CEBV+v+8GkYyabVobhwiXKYc5qHhZE-ZKFxywkQaQ@mail.gmail.com>
	<20110710.105730.1305564732068163754.fujita.tomonori@lab.ntt.co.jp>
	<CAJfuBxwhxhMpxBS6L7FANcqeyipjCR1cjhPraYVpOv55_weC6g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, thockin@hockin.org, netdev@vger.kernel.org
To: jim.cromie@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from tama500.ecl.ntt.co.jp ([129.60.39.148]:55622 "EHLO
	tama500.ecl.ntt.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751752Ab1GJCST convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 Jul 2011 22:18:19 -0400
In-Reply-To: <CAJfuBxwhxhMpxBS6L7FANcqeyipjCR1cjhPraYVpOv55_weC6g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 9 Jul 2011 20:10:17 -0600
Jim Cromie <jim.cromie@gmail.com> wrote:

>>>> Which pci_unmap_single are you talking about?
>>>>
>>>
>>>
>>> =A0 =A02131 static void netdev_tx_done(struct net_device *dev)
>>> =A0 =A02132 {
>>> ...
>>> =A0 =A02160 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 pci_unmap_single(np->pc=
i_dev,np->tx_dma[entry],
>>> =A0 =A02161 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 np->tx_skbuff[entry]->len,
>>> =A0 =A02162 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 PCI_DMA_TODEVICE);
>>
>> It's pci_unmap_single call for tx_dma buffers. We fixed
>> pci_unmap_single calls for rx_dma buffers.
>>
>> Looks like the driver correctlly uses pci_map_single and
>> pci_unmap_single for tx_dma buffers.
>>
>=20
> thanks for checking.
>=20
> and oops, the one I was referring to was this one,
> patched locally.
>=20
>=20
>     possible dma-debug error, unseen
>=20
> diff --git a/drivers/net/natsemi.c b/drivers/net/natsemi.c
> index e4bd202..0df7a47 100644
> --- a/drivers/net/natsemi.c
> +++ b/drivers/net/natsemi.c
> @@ -2007,8 +2007,8 @@ static void drain_tx(struct net_device *dev)
>=20
>         for (i =3D 0; i < TX_RING_SIZE; i++) {
>                 if (np->tx_skbuff[i]) {
> -                       pci_unmap_single(np->pci_dev,
> -                               np->tx_dma[i], np->tx_skbuff[i]->len,
> +                       pci_unmap_single(np->pci_dev, np->tx_dma[i],
> +                               np->tx_skbuff[i]->len + NATSEMI_PADDI=
NG,
>                                 PCI_DMA_TODEVICE);
>                         dev_kfree_skb(np->tx_skbuff[i]);
>                         dev->stats.tx_dropped++;
>=20
> again, I havent seen a warning here,
> either with or without this patch.
>=20
> Given the wording of the warning (mismatch, ie > or <, not =3D=3D)
> I presume I should get a warning if the PADDING is wrong here,
> and I actually run this codepath ?

I don't think you run this code path. And as I wrote, the current code
looks correct.
