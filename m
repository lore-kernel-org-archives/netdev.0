From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Fix and allocate less memory for ->priv'less netdevices
Date: Fri, 18 Apr 2008 15:43:58 -0700 (PDT)
Message-ID: <20080418.154358.247414309.davem@davemloft.net>
References: <200804181910.30178.adobriyan@parallels.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, devel@openvz.org, xemul@openvz.org
To: adobriyan@parallels.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33324
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751755AbYDRWn5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Apr 2008 18:43:57 -0400
In-Reply-To: <200804181910.30178.adobriyan@parallels.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexey Dobriyan <adobriyan@parallels.com>
Date: Fri, 18 Apr 2008 19:10:29 +0400

> This patch effectively reverts commit d0498d9ae1a5cebac363e38907266d5cd2eedf89
> aka "[NET]: Do not allocate unneeded memory for dev->priv alignment."
> It was found to be buggy because of final unconditional += NETDEV_ALIGN_CONST
> removal.
> 
> For example, for sizeof(struct net_device) being 2048 bytes, "alloc_size"
> was also 2048 bytes, but allocator with debugging options turned on started
> giving out !32-byte aligned memory resulting in redzones overwrites.
> 
> Patch does small optimization in ->priv'less case: bumping size to next
> 32-byte boundary was always done to ensure ->priv will also be aligned.
> But, no ->priv, no need to do that.
> 
> Signed-off-by: Alexey Dobriyan <adobriyan@sw.ru>

Thanks for finding and fixing this regression.

Patch applied.
