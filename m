From: David Miller <davem@davemloft.net>
Subject: Re: [net-next 2/8] bnx2x: add select queue callback
Date: Fri, 10 Dec 2010 14:11:31 -0800 (PST)
Message-ID: <20101210.141131.241939045.davem@davemloft.net>
References: <1291896556.8745.7.camel@lb-tlvb-dmitry>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eilong@broadcom.com
To: dmitry@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38625
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752922Ab0LJWLD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Dec 2010 17:11:03 -0500
In-Reply-To: <1291896556.8745.7.camel@lb-tlvb-dmitry>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Dmitry Kravkov" <dmitry@broadcom.com>
Date: Thu, 9 Dec 2010 14:09:16 +0200

> +#endif
> +	/* Select queue (if defined) adjust for fcoe */
> +	fp_index = skb_tx_hash(dev, skb) - FCOE_CONTEXT_USE;
> +
> +	return (fp_index >= 0 ? fp_index : 0);

This doesn't make any sense, and it's one of the reasons I really
hate the fact that drivers sometimes need to override the
select_queue method.

Because 9 times out of 10 they get it wrong.

You're mapping queues 0 --> FCOE_CONTEXT_USE to zero.

But that's not what you actually want.

You're actually trying to make non-FCOE traffic hash only amongst the
non-FCOE queues.

So make your code actually do that instead of screwing up the
distribution of the hash result.
