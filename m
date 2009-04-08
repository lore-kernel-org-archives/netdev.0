From: Yang Hongyang <yanghy@cn.fujitsu.com>
Subject: [PATCH]drivers/net/eql.c:fix a dev leakage
Date: Wed, 08 Apr 2009 11:06:27 +0800
Message-ID: <49DC14B3.9020308@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:55644 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751158AbZDHDGW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 7 Apr 2009 23:06:22 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

After dev_get_by_name(),we should follow a dev_put().build test only.

Signed-off-by: Yang Hongyang<yanghy@cn.fujitsu.com>

---
 drivers/net/eql.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/drivers/net/eql.c b/drivers/net/eql.c
index 51ead79..5210bb1 100644
--- a/drivers/net/eql.c
+++ b/drivers/net/eql.c
@@ -542,6 +542,8 @@ static int eql_s_slave_cfg(struct net_device *dev, slave_config_t __user *scp)
 	}
 	spin_unlock_bh(&eql->queue.lock);
 
+	dev_put(slave_dev);
+
 	return ret;
 }
 
-- 
1.6.0.3

-- 
Regards
Yang Hongyang
