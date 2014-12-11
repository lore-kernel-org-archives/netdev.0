From: Ezequiel Garcia <ezequiel.garcia@free-electrons.com>
Subject: Re: Bug: mv643xxx fails with highmem
Date: Thu, 11 Dec 2014 17:25:24 -0300
Message-ID: <5489FDB4.5060701@free-electrons.com>
References: <20141211194920.GR11285@n2100.arm.linux.org.uk> <20141211.151055.817876561546126576.davem@davemloft.net> <20141211202507.GS11285@n2100.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	Gregory CLEMENT <gregory.clement@free-electrons.com>
To: Russell King - ARM Linux <linux@arm.linux.org.uk>,
	David Miller <davem@davemloft.net>,
	Nimrod Andy <B38611@freescale.com>,
	Fabio Estevam <fabio.estevam@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from down.free-electrons.com ([37.187.137.238]:46450 "EHLO
	mail.free-electrons.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1758964AbaLKU1Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Dec 2014 15:27:16 -0500
In-Reply-To: <20141211202507.GS11285@n2100.arm.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/11/2014 05:25 PM, Russell King - ARM Linux wrote:
> On Thu, Dec 11, 2014 at 03:10:55PM -0500, David Miller wrote:
>> From: Russell King - ARM Linux <linux@arm.linux.org.uk>
>> Date: Thu, 11 Dec 2014 19:49:20 +0000
>>
>>> Commit 69ad0dd7af22 removed skb_frag_dma_map() in favour of mapping
>>> all fragments with dma_map_single().  This fails when the driver is
>>> used in an environment with highmem.
>>
>> This change looks really buggy to me.
>>
>> Unfortunately, all the changes he subsequently makes for software TS=
O
>> support depend upon this :-/
>>
>> The change is definitely wrong.
>=20
> Thanks for confirming where the bug is.
>=20
> Would other drivers need fixing for this as well?  Eg, fec_main.c
> does the following, and this driver is used on iMX6 which can also ha=
ve
> highmem:
>=20
> static int
> fec_enet_txq_submit_frag_skb(struct fec_enet_priv_tx_q *txq,
>                              struct sk_buff *skb,
>                              struct net_device *ndev)
> {
>                 bufaddr =3D page_address(this_frag->page.p) + this_fr=
ag->page_offset;
> ...
>                 addr =3D dma_map_single(&fep->pdev->dev, bufaddr, fra=
g_len,
>                                       DMA_TO_DEVICE);
>=20

And mvneta seems to have that pattern too: see mvneta_tx_frag_process()=
=2E
--=20
Ezequiel Garc=EDa, Free Electrons
Embedded Linux, Kernel and Android Engineering
http://free-electrons.com
