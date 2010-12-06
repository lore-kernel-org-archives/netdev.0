From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 1/2] af_packet: use vmalloc_to_page() instead for
 the addresss returned by vmalloc()
Date: Mon, 06 Dec 2010 13:01:01 -0800 (PST)
Message-ID: <20101206.130101.28800569.davem@davemloft.net>
References: <1291207940-17140-1-git-send-email-xiaosuo@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, jpirko@redhat.com, nhorman@tuxdriver.com,
	netdev@vger.kernel.org
To: xiaosuo@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44532
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753373Ab0LFVAe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Dec 2010 16:00:34 -0500
In-Reply-To: <1291207940-17140-1-git-send-email-xiaosuo@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Changli Gao <xiaosuo@gmail.com>
Date: Wed,  1 Dec 2010 20:52:20 +0800

> The following commit causes the pgv->buffer may point to the memory
> returned by vmalloc(). And we can't use virt_to_page() for the vmalloc
> address.
> 
> This patch introduces a new inline function pgv_to_page(), which calls
> vmalloc_to_page() for the vmalloc address, and virt_to_page() for the
> __get_free_pages address.
> 
> We used to increase page pointer to get the next page at the next page
> address, after Neil's patch, it is wrong, as the physical address may
> be not continuous. This patch also fixes this issue.
> 
>     commit 0e3125c755445664f00ad036e4fc2cd32fd52877
>     Author: Neil Horman <nhorman@tuxdriver.com>
>     Date:   Tue Nov 16 10:26:47 2010 -0800
> 
>     packet: Enhance AF_PACKET implementation to not require high order contiguous memory allocation (v4)
> 
> Signed-off-by: Changli Gao <xiaosuo@gmail.com>

Applied.
