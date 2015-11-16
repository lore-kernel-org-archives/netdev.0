From: Dragos Tatulea <dragos@endocode.com>
Subject: [PATCH] net: switchdev: fix return code of fdb_dump stub
Date: Mon, 16 Nov 2015 10:52:48 +0100
Message-ID: <5649A770.8090909@endocode.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "Samudrala, Sridhar" <sridhar.samudrala@intel.com>,
	Jiri Pirko <jiri@mellanox.com>, davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f50.google.com ([74.125.82.50]:36954 "EHLO
	mail-wm0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752688AbbKPJwv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Nov 2015 04:52:51 -0500
Received: by wmww144 with SMTP id w144so110916106wmw.0
        for <netdev@vger.kernel.org>; Mon, 16 Nov 2015 01:52:50 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

rtnl_fdb_dump always expects an index to be returned by the ndo_fdb_dump op,
but when CONFIG_NET_SWITCHDEV is off, it returns an error.

Fix that by returning the given unmodified idx.

A similar fix was 0890cf6cb6ab ("switchdev: fix return value of
switchdev_port_fdb_dump in case of error") but for the CONFIG_NET_SWITCHDEV=y
case.

Fixes: 45d4122ca7cd ("switchdev: add support for fdb add/del/dump via switchdev_port_obj ops.")
Signed-off-by: Dragos Tatulea <dragos@endocode.com>
---
 include/net/switchdev.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/include/net/switchdev.h b/include/net/switchdev.h
index bc865e2..bc5765a 100644
--- a/include/net/switchdev.h
+++ b/include/net/switchdev.h
@@ -323,7 +323,7 @@ static inline int switchdev_port_fdb_dump(struct sk_buff *skb,
                                          struct net_device *filter_dev,
                                          int idx)
 {
-       return -EOPNOTSUPP;
+       return idx;
 }
 
 static inline void switchdev_port_fwd_mark_set(struct net_device *dev,
