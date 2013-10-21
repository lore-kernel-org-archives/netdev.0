From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] netpoll: linearize skb before accessing its data
Date: Mon, 21 Oct 2013 18:23:19 -0400 (EDT)
Message-ID: <20131021.182319.625146263287554088.davem@davemloft.net>
References: <1382391080-1607-1-git-send-email-antonio@meshcoding.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: antonio@meshcoding.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44086 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751463Ab3JUWXX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Oct 2013 18:23:23 -0400
In-Reply-To: <1382391080-1607-1-git-send-email-antonio@meshcoding.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Antonio Quartulli <antonio@meshcoding.com>
Date: Mon, 21 Oct 2013 23:31:20 +0200

> __netpoll_rx() assumes that the data buffer of the received
> skb is linear and then passes it to rx_hook().
> However this is not true because the skb has not been
> linearized yet.
> 
> This can cause rx_hook() to access non allocated memory
> while parsing the received data.
> 
> Fix __netpoll_rx() by explicitly linearising the skb.
> 
> Signed-off-by: Antonio Quartulli <antonio@meshcoding.com>

It is rx_hook's obligation to access the SKB properly and not
assume that the SKB is linear.  It is very expensive to
linearize every SKB just for the sake of improperly implemented
receive hooks.

In particular the rx hooks must make use of interface such
as pskb_may_pull(), just like every other protocol does
on packet input processing, to make sure the area they want
to access is in the linear area.
