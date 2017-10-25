From: Julien Gomes <julien@arista.com>
Subject: [PATCH net] tun: allow positive return values on dev_get_valid_name() call
Date: Wed, 25 Oct 2017 11:50:50 -0700
Message-ID: <20171025185050.22102-1-julien@arista.com>
Cc: davem@davemloft.net, xiyou.wangcong@gmail.com,
        Julien Gomes <julien@arista.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from prod-mx.aristanetworks.com ([162.210.130.12]:20193 "EHLO
        prod-mx.aristanetworks.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S932287AbdJYS6I (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 25 Oct 2017 14:58:08 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If the name argument of dev_get_valid_name() contains "%d", it will try
to assign it a unit number in __dev__alloc_name() and return either the
unit number (>= 0) or an error code (< 0).
Considering positive values as error values prevent tun device creations
relying this mechanism, therefor we should only consider negative values
as errors here.

Signed-off-by: Julien Gomes <julien@arista.com>
---
 drivers/net/tun.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index ea29da91ea5a..4d2400c253ba 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -2253,7 +2253,7 @@ static int tun_set_iff(struct net *net, struct file *file, struct ifreq *ifr)
 		if (!dev)
 			return -ENOMEM;
 		err = dev_get_valid_name(net, dev, name);
-		if (err)
+		if (err < 0)
 			goto err_free_dev;
 
 		dev_net_set(dev, net);
-- 
2.14.2
