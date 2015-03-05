From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH net-next] ax25: Fix the build when CONFIG_INET is disabled
Date: Thu, 05 Mar 2015 06:54:00 -0600
Message-ID: <87pp8nip07.fsf@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:45359 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750758AbbCEM5g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Mar 2015 07:57:36 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


From: kbuild test robot <fengguang.wu@intel.com>
>
> >> net/ax25/ax25_ip.c:225:26: error: unknown type name 'sturct'
>     netdev_tx_t ax25_ip_xmit(sturct sk_buff *skb)
>                              ^
>
> vim +/sturct +225 net/ax25/ax25_ip.c
>
>    219				    unsigned short type, const void *daddr,
>    220				    const void *saddr, unsigned int len)
>    221	{
>    222		return -AX25_HEADER_LEN;
>    223	}
>    224
>  > 225	netdev_tx_t ax25_ip_xmit(sturct sk_buff *skb)
>    226	{
>    227		kfree_skb(skb);
>    228		return NETDEV_TX_OK;

Ooops I misspelled struct...

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 net/ax25/ax25_ip.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ax25/ax25_ip.c b/net/ax25/ax25_ip.c
index 8b35af4ef93e..7c646bb2c6f7 100644
--- a/net/ax25/ax25_ip.c
+++ b/net/ax25/ax25_ip.c
@@ -222,7 +222,7 @@ static int ax25_hard_header(struct sk_buff *skb, struct net_device *dev,
 	return -AX25_HEADER_LEN;
 }
 
-netdev_tx_t ax25_ip_xmit(sturct sk_buff *skb)
+netdev_tx_t ax25_ip_xmit(struct sk_buff *skb)
 {
 	kfree_skb(skb);
 	return NETDEV_TX_OK;
-- 
2.2.1
