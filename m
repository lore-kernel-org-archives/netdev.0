From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] xen-netfront: fix missing rx_refill_timer when
 allocate memory failed
Date: Mon, 18 Nov 2013 13:57:35 -0500 (EST)
Message-ID: <20131118.135735.467426814194053418.davem@davemloft.net>
References: <1384489573-16605-1-git-send-email-jieyue.majy@alibaba-inc.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, konrad.wilk@oracle.com,
	wei.liu2@citrix.com, jieyue.majy@alibaba-inc.com,
	david.vrabel@citrix.com, annie.li@oracle.com,
	boris.ostrovsky@oracle.com, xen-devel@lists.xenproject.org
To: majieyue@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49037 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752270Ab3KRTBJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Nov 2013 14:01:09 -0500
In-Reply-To: <1384489573-16605-1-git-send-email-jieyue.majy@alibaba-inc.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ma JieYue <majieyue@gmail.com>
Date: Fri, 15 Nov 2013 12:26:13 +0800

> From: Ma JieYue <jieyue.majy@alibaba-inc.com>
> 
> There was a bug in xennet_alloc_rx_buffers, when allocating page or
> sk_buff failed, and at the same time rx_batch queue not empty,
> the rx_refill_timer timer won't be scheduled. If finally the remaining
> request buffers in rx ring less than what backend driver expected,
> the backend driver would think of rx ring as full and start dropping packets.
> In such situation, there is no way for the netfront driver to recover
> automatically, so that the device can not work properly.
> 
> The patch fixes the problem by always scheduling rx_refill_timer timer when
> alloc_page or __netdev_alloc_skb fails, no matter whether rx_batch queue is
> empty or not. It ensures that the rx ring request buffers will finally meet
> the backend needs.
> 
> Signed-off-by: Ma JieYue <jieyue.majy@alibaba-inc.com>

Looks good, applied, thanks!
