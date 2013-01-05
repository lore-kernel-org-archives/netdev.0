From: =?UTF-8?B?UmFmYcWCIE1pxYJlY2tp?= <zajec5@gmail.com>
Subject: Re: [PATCH] bgmac: driver for GBit MAC core on BCMA bus
Date: Sat, 5 Jan 2013 13:08:37 +0100
Message-ID: <CACna6ry4fQCvh_hSKooNi1Lq=ftjVD=tNeDijnfW1gnnvGzLeQ@mail.gmail.com>
References: <1356363222-16672-1-git-send-email-zajec5@gmail.com>
	<20121226231721.GA8243@electric-eye.fr.zoreil.com>
	<CACna6rydCnf9tjsueOQRvxPQz5_u_h6b=q9j_pTQN+j7_+6uLA@mail.gmail.com>
	<20130103203027.GA4305@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f182.google.com ([74.125.82.182]:50634 "EHLO
	mail-we0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755394Ab3AEMOK convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 Jan 2013 07:14:10 -0500
Received: by mail-we0-f182.google.com with SMTP id u54so8346514wey.41
        for <netdev@vger.kernel.org>; Sat, 05 Jan 2013 04:14:09 -0800 (PST)
In-Reply-To: <20130103203027.GA4305@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2013/1/3 Francois Romieu <romieu@fr.zoreil.com>:
> Rafa=C5=82 Mi=C5=82ecki <zajec5@gmail.com> :
>> > The driver should stop queueing after its processing if it detects=
 that
>> > it can't handle more requests.
>>
>> I think it's what the code does... netif_stop_queue and return
>> NETDEV_TX_BUSY. Anything wrong about it?
>
> The driver does not hold its promise to send the packet. It should
> netif_stop_queue and return NETDEV_TX_OK after the last transmitted
> packet.

We really need some good explanation for NETDEV_TX_BUSY somewhere
(documentation!).

I've checked some drivers and:

1) b44.c
In case of:
> if (unlikely(TX_BUFFS_AVAIL(bp) < 1)) {
it does netif_stop_queue and returns NETDEV_TX_BUSY

2) sky2.c
In case of:
> if (unlikely(tx_avail(sky2) < tx_le_req(skb)))
it just returns NETDEV_TX_BUSY

3) jme.2
In case of:
> if (unlikely(idx < 0)) {
it does netif_stop_queue and returns NETDEV_TX_BUSY

4) de2104x.c
In case of:
> if (tx_free =3D=3D 0) {
it does netif_stop_queue and returns NETDEV_TX_BUSY

So there are many drivers doing the same mistake I did.

--=20
Rafa=C5=82
