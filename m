From: David Miller <davem@davemloft.net>
Subject: Re: [net] net: fix double free issue of skbuff
Date: Mon, 29 Feb 2016 12:01:54 -0500 (EST)
Message-ID: <20160229.120154.1521809488996597623.davem@davemloft.net>
References: <1456748573-21586-1-git-send-email-zhangshengju@cmss.chinamobile.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: zhangshengju@cmss.chinamobile.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47212 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751390AbcB2RB6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Feb 2016 12:01:58 -0500
In-Reply-To: <1456748573-21586-1-git-send-email-zhangshengju@cmss.chinamobile.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Zhang Shengju <zhangshengju@cmss.chinamobile.com>
Date: Mon, 29 Feb 2016 12:22:53 +0000

> If skb_reorder_vlan_header() failed, skb is freed and NULL is returned.
> Then at skb_vlan_untag(), it will free skbuff again which cause double
> free.

The 'skb' local variable in this case will be set to "NULL", calling
kfree_skb() on NULL doesn't do anything.

> This patch removes kfree_skb() call in function skb_reorder_vlan_header().
> 
> Signed-off-by: Zhang Shengju <zhangshengju@cmss.chinamobile.com>

Please analyze the complete control path of the caller of this
function, and you'll find that everything is fine.
