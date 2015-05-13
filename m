From: Kevin Hilman <khilman@kernel.org>
Subject: Re: [net-next PATCH] net: Reserve skb headroom and set skb->dev even if using __alloc_skb
Date: Wed, 13 May 2015 14:35:51 -0700
Message-ID: <7h8ucs6tzc.fsf@deeprootsystems.com>
References: <20150513182738.GA28201@saruman.tx.rr.com>
	<20150513203413.8252.98057.stgit@ahduyck-vm-fedora22>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-kernel@vger.kernel.org, balbi@ti.com, davem@davemloft.net,
	tony@atomide.com, netdev@vger.kernel.org,
	linux-omap@vger.kernel.org, linux-arm-kernel@lists.infradead.org
To: Alexander Duyck <alexander.h.duyck@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f177.google.com ([209.85.192.177]:36738 "EHLO
	mail-pd0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965006AbbEMVfz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 May 2015 17:35:55 -0400
Received: by pdea3 with SMTP id a3so63442687pde.3
        for <netdev@vger.kernel.org>; Wed, 13 May 2015 14:35:54 -0700 (PDT)
In-Reply-To: <20150513203413.8252.98057.stgit@ahduyck-vm-fedora22> (Alexander
	Duyck's message of "Wed, 13 May 2015 13:34:13 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Alexander Duyck <alexander.h.duyck@redhat.com> writes:

> When I had inlined __alloc_rx_skb into __netdev_alloc_skb and
> __napi_alloc_skb I had overlooked the fact that there was a return in the
> __alloc_rx_skb.  As a result we weren't reserving headroom or setting the
> skb->dev in certain cases.  This change corrects that by adding a couple of
> jump labels to jump to depending on __alloc_skb either succeeding or failing.
>
> Fixes: 9451980a6646 ("net: Use cached copy of pfmemalloc to avoid accessing page")
> Reported-by: Felipe Balbi <balbi@ti.com>
> Signed-off-by: Alexander Duyck <alexander.h.duyck@redhat.com>

Tested this on top of next-20150513 on an ARM/OMAP
(am335x-boneblack.dts) an it fixes the boot problem for me.

Tested-by: Kevin Hilman <khilman@linaro.org>

Kevin
