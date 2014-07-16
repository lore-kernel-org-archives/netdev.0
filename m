From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 3/7] tipc: add new functions for multicast and
 broadcast distribution
Date: Wed, 16 Jul 2014 15:10:50 -0700 (PDT)
Message-ID: <20140716.151050.974076735111970390.davem@davemloft.net>
References: <1405446370-11781-1-git-send-email-jon.maloy@ericsson.com>
	<1405446370-11781-4-git-send-email-jon.maloy@ericsson.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, paul.gortmaker@windriver.com,
	erik.hugne@ericsson.com, ying.xue@windriver.com, maloy@donjonn.com,
	tipc-discussion@lists.sourceforge.net
To: jon.maloy@ericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55348 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752674AbaGPWKv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Jul 2014 18:10:51 -0400
In-Reply-To: <1405446370-11781-4-git-send-email-jon.maloy@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jon Maloy <jon.maloy@ericsson.com>
Date: Tue, 15 Jul 2014 13:46:06 -0400

> +	/* Copy header if single buffer */
> +	if (!buf->next) {
> +		hdr_sz = skb_headroom(buf) + msg_hdr_sz(buf_msg(buf));
> +		head = __pskb_copy(buf, hdr_sz, GFP_ATOMIC);
> +		if (likely(head))
> +			return head;
> +		return NULL;

These last four lines are simply:

		return __pskb_copy(buf, hdr_sz, GFP_ATOMIC);

Don't make this code more complicated than necessary :)
