From: Ayaz Abdulla <AAbdulla@nvidia.com>
Subject: RE: [PATCH] forcedeth: fix dma api mismatches
Date: Thu, 18 Jun 2009 10:33:43 -0700
Message-ID: <1FC56210173BB445BD77F608D6FB8D03036AA43501@HQMAIL03.nvidia.com>
References: <20090618.004642.31377117.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: 'David Miller' <davem@davemloft.net>,
	"eric.dumazet@gmail.com" <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hqemgate04.nvidia.com ([216.228.112.152]:17212 "EHLO
	hqemgate04.nvidia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753136AbZFRRdn convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Jun 2009 13:33:43 -0400
In-Reply-To: <20090618.004642.31377117.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Doing a quick indentifier search on 2.6.17 shows that pci_unmap_page() just calls pci_unmap_single().

I think this will just add extra clutter. We can just add a comment in the code instead that they perform the same thing.

Ayaz




-----Original Message-----
From: David Miller [mailto:davem@davemloft.net]
Sent: Thursday, June 18, 2009 12:47 AM
To: eric.dumazet@gmail.com
Cc: Ayaz Abdulla; netdev@vger.kernel.org
Subject: Re: [PATCH] forcedeth: fix dma api mismatches


From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 18 Jun 2009 09:17:59 +0200

> Please find following patch, candidate for stable, but alas not tested
> since I dont have the hardware. I hit this on a 2.6.30 kernel on a machine
> I dont have access anymore.
>
> Thank you
>
> [PATCH] forcedeth: fix dma api mismatches
>
> forcedeth doesnt use properly dma api in its tx completion path
> and in nv_loopback_test()
>
> pci_map_single() should be paired with pci_unmap_single()
> pci_map_page() should be paired with pci_unmap_page()
>
> forcedeth xmit path uses pci_map_single() & pci_map_page(),
> but tx completion path only uses pci_unmap_single()
>
> nv_loopback_test() uses pci_map_single() & pci_unmap_page()
>
> Add a dma_single field in struct nv_skb_map, and
> define a helper function nv_unmap_txskb
>
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> CC: Ayaz Abdulla <aabdulla@nvidia.com>

I'm going to apply this to net-next-2.6 now since it looks
painfully correct to me.
-----------------------------------------------------------------------------------
This email message is for the sole use of the intended recipient(s) and may contain
confidential information.  Any unauthorized review, use, disclosure or distribution
is prohibited.  If you are not the intended recipient, please contact the sender by
reply email and destroy all copies of the original message.
-----------------------------------------------------------------------------------
