From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: 3.2.8/amd64 full interrupt hangs and deadlocks under big
 network copies (page allocation failure)
Date: Mon, 09 Apr 2012 21:11:12 +0200
Message-ID: <1333998672.3007.245.camel@edumazet-glaptop>
References: <20120409172051.GR32290@merlins.org>
	 <20120409.141241.1216091936509309354.davem@davemloft.net>
	 <20120409183632.GO29342@merlins.org>
	 <20120409.143710.879746943062854492.davem@davemloft.net>
	 <4F83316F.20504@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: marc@merlins.org, David Miller <davem@davemloft.net>,
	bhutchings@solarflare.com, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org
To: Larry Finger <Larry.Finger@lwfinger.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:61267 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757647Ab2DITLT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Apr 2012 15:11:19 -0400
In-Reply-To: <4F83316F.20504@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2012-04-09 at 13:58 -0500, Larry Finger wrote:

> As it happens with both iwlwifi and e1000e, it seems to be a problem further up 
> the food chain.
> 
> I don't know much about iwlwifi, but loading it with the module parameter 
> "amsdu_size_8K=0" seems to select 4K rather than 8K buffers. That will hurt 
> performance, but it should fix the memory fragmentation. There have also been 
> some problems with aggregation that are fixed by setting the option "11n_disable=3".

I think Marc posted stack traces showing problem on transmit side.

09:44:12   [<ffffffff810ba394>] ? __alloc_pages_nodemask+0x6b2/0x726
09:44:12   [<ffffffff810e9081>] ? kmem_getpages+0x4c/0xd9
09:44:12   [<ffffffff810e9081>] ? kmem_getpages+0x4c/0xd9
09:44:12   [<ffffffff810ea421>] ? fallback_alloc+0x123/0x1c2
09:44:12   [<ffffffff8127daae>] ? pskb_expand_head+0xe0/0x24a
09:44:12   [<ffffffff810ea923>] ? __kmalloc+0xba/0x112
09:44:12   [<ffffffff8127daae>] ? pskb_expand_head+0xe0/0x24a
09:44:12   [<ffffffffa07a81c0>] ? ieee80211_skb_resize+0x64/0x9d [mac80211]
09:44:12   [<ffffffffa07aa087>] ? ieee80211_subif_start_xmit+0x68e/0x80c [mac80211]
09:44:12   [<ffffffffa07922c8>] ? ieee80211_tx_status_irqsafe+0x2e/0x7f [mac80211]
09:44:12   [<ffffffff812877f3>] ? dev_hard_start_xmit+0x3fc/0x543
09:44:12   [<ffffffff81070551>] ? arch_local_irq_save+0x11/0x17
09:44:12   [<ffffffff8129da01>] ? sch_direct_xmit+0x5e/0x12f
09:44:12   [<ffffffff8129dbc9>] ? __qdisc_run+0xf7/0x10f

I dont really understand how it can happen, with MTU=1500
