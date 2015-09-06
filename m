From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH net 1/1] r8169: fix sleepable allocation during netdevice
 stats retrieval.
Date: Sun, 6 Sep 2015 22:20:26 +0200
Message-ID: <20150906202026.GA19371@electric-eye.fr.zoreil.com>
References: <55E9A518.3080906@gmail.com>
 <20150904.113657.2146226970417029162.davem@davemloft.net>
 <20150904205904.GA32346@electric-eye.fr.zoreil.com>
 <20150906101954.GE30539@calimero.vinschen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	pomidorabelisima@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:58890 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752826AbbIFUUz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 6 Sep 2015 16:20:55 -0400
Content-Disposition: inline
In-Reply-To: <20150906101954.GE30539@calimero.vinschen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Corinna Vinschen <vinschen@redhat.com> :
[...]
> - I'm pretty new to this stuff, so I don't understand this:
> 
>   The dma_alloc_coherent(...,GFP_KERNEL) call is not new in the code,
>   it's there since at least 2010.  It appears to work fine in the
>   context of @get_ethtool_stats.  Why does this not work in the context
>   of @ndo_get_stats64?

get_ethtool_stats is only called under RTNL, not with spinlock held.

ndo_get_stats64 is called under dev_base_lock from sysfs.

-- 
Ueimor
