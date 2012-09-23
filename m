From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] netlink: kill netlink_set_nonroot
Date: Sun, 23 Sep 2012 02:09:52 -0400 (EDT)
Message-ID: <20120923.020952.2024265275496412823.davem@davemloft.net>
References: <1346934712-3056-1-git-send-email-pablo@netfilter.org>
	<alpine.LNX.2.01.1209230700120.2498@nerf07.vanv.qr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: pablo@netfilter.org, netdev@vger.kernel.org
To: jengelh@inai.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37933 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753640Ab2IWGJ4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 23 Sep 2012 02:09:56 -0400
In-Reply-To: <alpine.LNX.2.01.1209230700120.2498@nerf07.vanv.qr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jan Engelhardt <jengelh@inai.de>
Date: Sun, 23 Sep 2012 07:00:42 +0200 (CEST)

> 
> On Thursday 2012-09-06 14:31, pablo@netfilter.org wrote:
> 
>> /* optional Netlink kernel configuration parameters */
>> struct netlink_kernel_cfg {
>> 	unsigned int	groups;
>> 	void		(*input)(struct sk_buff *skb);
>> 	struct mutex	*cb_mutex;
>> 	void		(*bind)(int group);
>>+	unsigned int	flags;
>> };
> 
> Putting flags next to groups would reduce the hole there.

Works for me:

--------------------
[PATCH] netlink: Rearrange netlink_kernel_cfg to save space on 64-bit.

Suggested by Jan Engelhardt.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/linux/netlink.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/include/linux/netlink.h b/include/linux/netlink.h
index b3dc992..f80c56a 100644
--- a/include/linux/netlink.h
+++ b/include/linux/netlink.h
@@ -183,10 +183,10 @@ extern void netlink_table_ungrab(void);
 /* optional Netlink kernel configuration parameters */
 struct netlink_kernel_cfg {
 	unsigned int	groups;
+	unsigned int	flags;
 	void		(*input)(struct sk_buff *skb);
 	struct mutex	*cb_mutex;
 	void		(*bind)(int group);
-	unsigned int	flags;
 };
 
 extern struct sock *__netlink_kernel_create(struct net *net, int unit,
-- 
1.7.11.4


 
