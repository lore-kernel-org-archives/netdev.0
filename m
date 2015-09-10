From: poma <pomidorabelisima@gmail.com>
Subject: Re: [PATCH net 1/1] r8169: fix sleepable allocation during netdevice
 stats retrieval.
Date: Thu, 10 Sep 2015 02:38:13 +0200
Message-ID: <55F0D0F5.7060908@gmail.com>
References: <20150909155404.GC19913@calimero.vinschen.de>
 <20150909155511.GD19913@calimero.vinschen.de> <55F07BBC.9020308@gmail.com>
 <20150909.120405.378304490596297372.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, romieu@fr.zoreil.com, m8t@gandi.net,
	benedikt.meurer@unix-ag.uni-siegen.de, bernhard.walle@gmx.de,
	hscholz@raisdorf.net, frivoal@xfce.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f171.google.com ([209.85.212.171]:33732 "EHLO
	mail-wi0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751469AbbIJAiR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Sep 2015 20:38:17 -0400
Received: by wiclk2 with SMTP id lk2so9594905wic.0
        for <netdev@vger.kernel.org>; Wed, 09 Sep 2015 17:38:16 -0700 (PDT)
In-Reply-To: <20150909.120405.378304490596297372.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09.09.2015 21:04, David Miller wrote:
> From: poma <pomidorabelisima@gmail.com>
> Date: Wed, 9 Sep 2015 20:34:36 +0200
> 
>> [  230.110233]  [<ffffffff810218e6>] dma_generic_alloc_coherent+0x96/0x130
>> [  230.110242]  [<ffffffff81069865>] x86_swiotlb_alloc_coherent+0x25/0x50
>> [  230.110250]  [<ffffffff810215fd>] dma_alloc_attrs+0x6d/0xe0
>> [  230.110265]  [<ffffffffa002e25e>] rtl8169_map_counters+0x3e/0x70 [r8169]
>> [  230.110277]  [<ffffffffa002f674>] rtl8169_update_counters+0x64/0x140 [r8169]
>> [  230.110289]  [<ffffffffa002f8ff>] rtl8169_get_stats64+0xbf/0x130 [r8169]
>> [  230.110299]  [<ffffffff81700b74>] dev_get_stats+0x54/0x100
> 
> The patch in question removes this call to dma_alloc_coherent() so you
> aren't running a kernel which actually has the patch applied.
> 

Here is the obvious example - in use is what is patched:

$ grep MODULE_DESCRIPTION rpmbuild/BUILD/kernel-4.2.fc24/linux-4.3.0-0.rc0.git9.1.fc24.x86_64/drivers/net/ethernet/realtek/r8169.c
MODULE_DESCRIPTION("RealTek RTL-8169 Gigabit Ethernet driver patched with [PATCH v2] r8169: Fix sleeping function called during get_stats64");

$ modinfo -n r8169; modinfo -d r8169
/lib/modules/4.3.0-0.rc0.git9.1.fc24.x86_64/updates/r8169.ko
RealTek RTL-8169 Gigabit Ethernet driver patched with [PATCH v2] r8169: Fix sleeping function called during get_stats64
