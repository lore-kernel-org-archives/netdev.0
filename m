From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v1 2/2] drivers: net: xgene: Adding support for TSO
Date: Mon, 17 Aug 2015 17:27:11 -0700 (PDT)
Message-ID: <20150817.172711.1231947431645678967.davem@davemloft.net>
References: <1439847185-22046-1-git-send-email-isubramanian@apm.com>
	<1439847185-22046-3-git-send-email-isubramanian@apm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	kchudgar@apm.com, patches@apm.com
To: isubramanian@apm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37161 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751124AbbHRA1O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Aug 2015 20:27:14 -0400
In-Reply-To: <1439847185-22046-3-git-send-email-isubramanian@apm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Iyappan Subramanian <isubramanian@apm.com>
Date: Mon, 17 Aug 2015 14:33:05 -0700

> +			/* HW requires all header resides in the first buffer */
> +			if (skb_is_nonlinear(skb) &&
> +			    (skb_headlen(skb) < hdr_len)) {
> +				netdev_warn(ndev, "Headers are required to reside in header buffer\n");
> +				dev_kfree_skb(skb);
> +				return 0;
> +			}

You can't just drop the packet in this situation.

Instead, you must at least try to linearize the header to fit your
needs.
