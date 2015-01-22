From: Ezequiel Garcia <ezequiel.garcia@free-electrons.com>
Subject: Re: [PATCH v2] net: mv643xx_eth: Fix highmem support in non-TSO egress
 path
Date: Thu, 22 Jan 2015 10:26:56 -0300
Message-ID: <54C0FAA0.9040002@free-electrons.com>
References: <1421928859-17923-1-git-send-email-ezequiel.garcia@free-electrons.com> <063D6719AE5E284EB5DD2968C1650D6D1CAD0E4F@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"B38611@freescale.com" <B38611@freescale.com>,
	"fabio.estevam@freescale.com" <fabio.estevam@freescale.com>
To: David Laight <David.Laight@ACULAB.COM>,
	David Miller <davem@davemloft.net>,
	Russell King <linux@arm.linux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from down.free-electrons.com ([37.187.137.238]:43786 "EHLO
	mail.free-electrons.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750803AbbAVN3B (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Jan 2015 08:29:01 -0500
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D1CAD0E4F@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/22/2015 09:40 AM, David Laight wrote:
> From: Ezequiel Garcia
>> Commit 69ad0dd7af22b61d9e0e68e56b6290121618b0fb
>> Author: Ezequiel Garcia <ezequiel.garcia@free-electrons.com>
>> Date:   Mon May 19 13:59:59 2014 -0300
>>
>>     net: mv643xx_eth: Use dma_map_single() to map the skb fragments
>>
>> caused a nasty regression by removing the support for highmem skb
>> fragments. By using page_address() to get the address of a fragment'=
s
>> page, we are assuming a lowmem page. However, such assumption is inc=
orrect,
>> as fragments can be in highmem pages, resulting in very nasty issues=
=2E
>>
>> This commit fixes this by using the skb_frag_dma_map() helper,
>> which takes care of mapping the skb fragment properly. Additionally,
>> the type of mapping is now tracked, so it can be unmapped using
>> dma_unmap_page or dma_unmap_single when appropriate.
>>
>> Fixes: 69ad0dd7af22 ("net: mv643xx_eth: Use dma_map_single() to map =
the skb fragments")
>> Reported-by: Russell King <rmk+kernel@arm.linux.org.uk>
>> Signed-off-by: Ezequiel Garcia <ezequiel.garcia@free-electrons.com>
> ...
>> @@ -2048,6 +2068,11 @@ static int txq_init(struct mv643xx_eth_privat=
e *mp, int index)
>>  					nexti * sizeof(struct tx_desc);
>>  	}
>>
>> +	txq->tx_desc_mapping =3D kcalloc(txq->tx_ring_size, sizeof(char),
>> +				       GFP_KERNEL);
>> +	if (!txq->tx_desc_mapping)
>> +		return -ENOMEM;
>> +
>>  	/* Allocate DMA buffers for TSO MAC/IP/TCP headers */
>>  	txq->tso_hdrs =3D dma_alloc_coherent(mp->dev->dev.parent,
>>  					   txq->tx_ring_size * TSO_HEADER_SIZE,
>=20
> I'm guessing there is an error path for dma_alloc_coherent() failing.
> You've not modified it to free tx_desc_mapping.
>=20

Yeah, you guess right.
--=20
Ezequiel Garc=EDa, Free Electrons
Embedded Linux, Kernel and Android Engineering
http://free-electrons.com
