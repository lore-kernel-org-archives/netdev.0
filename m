From: Jim Cromie <jim.cromie@gmail.com>
Subject: Re: [PATCH] natsemi: silence dma-debug warnings
Date: Sat, 9 Jul 2011 20:10:17 -0600
Message-ID: <CAJfuBxwhxhMpxBS6L7FANcqeyipjCR1cjhPraYVpOv55_weC6g@mail.gmail.com>
References: <CAJfuBxxKYNvaw5t4jWMP4+hYcw42SkwLiiahVdeezpfh6AsLBA@mail.gmail.com>
 <20110710.102039.1305564732068163396.fujita.tomonori@lab.ntt.co.jp>
 <CAJfuBxxs=CEBV+v+8GkYyabVobhwiXKYc5qHhZE-ZKFxywkQaQ@mail.gmail.com> <20110710.105730.1305564732068163754.fujita.tomonori@lab.ntt.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, thockin@hockin.org, netdev@vger.kernel.org
To: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f46.google.com ([209.85.210.46]:55865 "EHLO
	mail-pz0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751752Ab1GJCKr convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 Jul 2011 22:10:47 -0400
Received: by pzk9 with SMTP id 9so2196451pzk.19
        for <netdev@vger.kernel.org>; Sat, 09 Jul 2011 19:10:47 -0700 (PDT)
In-Reply-To: <20110710.105730.1305564732068163754.fujita.tomonori@lab.ntt.co.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>>> Which pci_unmap_single are you talking about?
>>>
>>
>>
>> =A0 =A02131 static void netdev_tx_done(struct net_device *dev)
>> =A0 =A02132 {
>> ...
>> =A0 =A02160 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 pci_unmap_single(np->pci=
_dev,np->tx_dma[entry],
>> =A0 =A02161 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 np->tx_skbuff[entry]->len,
>> =A0 =A02162 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 PCI_DMA_TODEVICE);
>
> It's pci_unmap_single call for tx_dma buffers. We fixed
> pci_unmap_single calls for rx_dma buffers.
>
> Looks like the driver correctlly uses pci_map_single and
> pci_unmap_single for tx_dma buffers.
>

thanks for checking.

and oops, the one I was referring to was this one,
patched locally.


    possible dma-debug error, unseen

diff --git a/drivers/net/natsemi.c b/drivers/net/natsemi.c
index e4bd202..0df7a47 100644
--- a/drivers/net/natsemi.c
+++ b/drivers/net/natsemi.c
@@ -2007,8 +2007,8 @@ static void drain_tx(struct net_device *dev)

        for (i =3D 0; i < TX_RING_SIZE; i++) {
                if (np->tx_skbuff[i]) {
-                       pci_unmap_single(np->pci_dev,
-                               np->tx_dma[i], np->tx_skbuff[i]->len,
+                       pci_unmap_single(np->pci_dev, np->tx_dma[i],
+                               np->tx_skbuff[i]->len + NATSEMI_PADDING=
,
                                PCI_DMA_TODEVICE);
                        dev_kfree_skb(np->tx_skbuff[i]);
                        dev->stats.tx_dropped++;

again, I havent seen a warning here,
either with or without this patch.

Given the wording of the warning (mismatch, ie > or <, not =3D=3D)
I presume I should get a warning if the PADDING is wrong here,
and I actually run this codepath ?
