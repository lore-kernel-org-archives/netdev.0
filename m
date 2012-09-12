From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net_tx_action: Call trace_consume_skb() instead of
 trace_kfree_skb()
Date: Wed, 12 Sep 2012 15:39:49 +0200
Message-ID: <1347457189.13103.990.camel@edumazet-glaptop>
References: <1347406098-22071-1-git-send-email-sbohrer@rgmadvisors.com>
	 <1347435199.13103.690.camel@edumazet-glaptop>
	 <20120912132055.GA2884@BohrerMBP.rgmadvisors.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sanagi.koki@jp.fujitsu.com,
	davem@davemloft.net
To: Shawn Bohrer <sbohrer@rgmadvisors.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:52006 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750809Ab2ILNjy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Sep 2012 09:39:54 -0400
Received: by eekc1 with SMTP id c1so1306774eek.19
        for <netdev@vger.kernel.org>; Wed, 12 Sep 2012 06:39:53 -0700 (PDT)
In-Reply-To: <20120912132055.GA2884@BohrerMBP.rgmadvisors.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-09-12 at 08:20 -0500, Shawn Bohrer wrote:

> But I guess your question is who puts the skb on the completion_queue.
> In my case it looks like:
> 
> dev_kfree_skb_irq()
> dev_kfree_skb_any()
> mlx4_en_free_tx_desc()
> mlx4_en_process_tx_cq()
> mlx4_en_xmit()
> dev_hard_start_xmit()
> # from here up the stack there seems to be several paths one of which is
> dev_queue_xmit()
> ip_finish_output()

> Does this answer your question about how I'm hitting this tracepoint?

Yes : this driver can do TX completion from its start_xmit() as well...


We need to add new helpers for dev_kfree_skb_any() and
dev_kfree_skb_irq(), but its quite a lot of work.

An alternative would be to set a bit in skb (skb->consumed)
