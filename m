From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 3/3] enic: fix memory leak in rq_clean
Date: Wed, 10 Jun 2015 23:43:22 -0700 (PDT)
Message-ID: <20150610.234322.1344906421619743139.davem@davemloft.net>
References: <1434003776-31840-1-git-send-email-_govind@gmx.com>
	<1434003776-31840-3-git-send-email-_govind@gmx.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ssujith@cisco.com, benve@cisco.com
To: _govind@gmx.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58504 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751101AbbFKGnX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Jun 2015 02:43:23 -0400
In-Reply-To: <1434003776-31840-3-git-send-email-_govind@gmx.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Govindarajulu Varadarajan <_govind@gmx.com>
Date: Thu, 11 Jun 2015 11:52:56 +0530

> When incoming packet qualifies for rx_copybreak, we copy the data to newly
> allocated skb. We do not free/unmap the original buffer. At this point driver
> assumes this buffer is unallocated. When enic_rq_alloc_buf() is called for
> buffer allocation, it checks if buf->os_buf is NULL. If its not NULL that means
> buffer can be re-used.
> 
> When vnic_rq_clean() is called for freeing all rq buffers, and if the
> rx_copybreak reused buffer falls outside the used desc, we do not free the
> buffer. The following trace is observer when dma-debug is enabled.
> 
> Fix is to walk through complete ring and clean if buffer is present.
 ...
> Signed-off-by: Govindarajulu Varadarajan <_govind@gmx.com>

Applied.
