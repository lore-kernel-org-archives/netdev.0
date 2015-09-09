From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 1/1] r8169: fix sleepable allocation during
 netdevice stats retrieval.
Date: Wed, 09 Sep 2015 12:04:05 -0700 (PDT)
Message-ID: <20150909.120405.378304490596297372.davem@davemloft.net>
References: <20150909155404.GC19913@calimero.vinschen.de>
	<20150909155511.GD19913@calimero.vinschen.de>
	<55F07BBC.9020308@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, romieu@fr.zoreil.com, m8t@gandi.net,
	benedikt.meurer@unix-ag.uni-siegen.de, bernhard.walle@gmx.de,
	hscholz@raisdorf.net, frivoal@xfce.org
To: pomidorabelisima@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34066 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751620AbbIITEI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Sep 2015 15:04:08 -0400
In-Reply-To: <55F07BBC.9020308@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: poma <pomidorabelisima@gmail.com>
Date: Wed, 9 Sep 2015 20:34:36 +0200

> [  230.110233]  [<ffffffff810218e6>] dma_generic_alloc_coherent+0x96/0x130
> [  230.110242]  [<ffffffff81069865>] x86_swiotlb_alloc_coherent+0x25/0x50
> [  230.110250]  [<ffffffff810215fd>] dma_alloc_attrs+0x6d/0xe0
> [  230.110265]  [<ffffffffa002e25e>] rtl8169_map_counters+0x3e/0x70 [r8169]
> [  230.110277]  [<ffffffffa002f674>] rtl8169_update_counters+0x64/0x140 [r8169]
> [  230.110289]  [<ffffffffa002f8ff>] rtl8169_get_stats64+0xbf/0x130 [r8169]
> [  230.110299]  [<ffffffff81700b74>] dev_get_stats+0x54/0x100

The patch in question removes this call to dma_alloc_coherent() so you
aren't running a kernel which actually has the patch applied.
