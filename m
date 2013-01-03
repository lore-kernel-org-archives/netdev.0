From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH] bgmac: driver for GBit MAC core on BCMA bus
Date: Thu, 3 Jan 2013 21:30:27 +0100
Message-ID: <20130103203027.GA4305@electric-eye.fr.zoreil.com>
References: <1356363222-16672-1-git-send-email-zajec5@gmail.com> <20121226231721.GA8243@electric-eye.fr.zoreil.com> <CACna6rydCnf9tjsueOQRvxPQz5_u_h6b=q9j_pTQN+j7_+6uLA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
To: =?utf-8?B?UmFmYcWCIE1pxYJlY2tp?= <zajec5@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:40044 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753855Ab3ACU6A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Jan 2013 15:58:00 -0500
Content-Disposition: inline
In-Reply-To: <CACna6rydCnf9tjsueOQRvxPQz5_u_h6b=q9j_pTQN+j7_+6uLA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Rafa=C5=82 Mi=C5=82ecki <zajec5@gmail.com> :
[...]
> bgmac_chip_reset also does different things, so I can't just remove
> bgmac_chip_reset from bgmac_probe. I could add some parameter to
> bgmac_chip_reset to let it know if DMA should be reset as well, but
> I'm note sure about the advantage.

=46orget it. I was completely wrong.

[...]
> > The driver should stop queueing after its processing if it detects =
that
> > it can't handle more requests.
>=20
> I think it's what the code does... netif_stop_queue and return
> NETDEV_TX_BUSY. Anything wrong about it?

The driver does not hold its promise to send the packet. It should
netif_stop_queue and return NETDEV_TX_OK after the last transmitted
packet.

[...]
> > Are we sure that the hardware will never read a descriptor where ct=
l0 is
> > set and ctl1 is not (start_xmit, dma starts, competing start_xmit, =
oops) ?
>=20
> Do you mean more that one ->ndo_start_xmit(...) can be executed at a
> time ?

No. I was just wondering if a sequence of start_xmit could compete with
hardware DMA but I missed the BGMAC_DMA_TX_INDEX below. You may want a
mmiowb after the write to BGMAC_DMA_TX_INDEX though.

--=20
Ueimor
