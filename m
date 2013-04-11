From: Nikolay Aleksandrov <nikolay@redhat.com>
Subject: [PATCHv2 2/2] bonding: IFF_BONDING is not stripped on enslave failure
Date: Thu, 11 Apr 2013 21:18:56 +0200
Message-ID: <1365707936-5073-3-git-send-email-nikolay@redhat.com>
References: <1365707936-5073-1-git-send-email-nikolay@redhat.com>
Cc: andy@greyhouse.net, fubar@us.ibm.com, davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:18120 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752828Ab3DKTWZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 11 Apr 2013 15:22:25 -0400
In-Reply-To: <1365707936-5073-1-git-send-email-nikolay@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

While enslaving a new device and after IFF_BONDING flag is set, in case
of failure it is not stripped from the device's priv_flags while
cleaning up, which could lead to other problems.
Cleaning at err_close because the flag is set after dev_open().

v2: no change

Signed-off-by: Nikolay Aleksandrov <nikolay@redhat.com>
---
 drivers/net/bonding/bond_main.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 15c675c..232b129 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -1906,6 +1906,7 @@ err_detach:
 	write_unlock_bh(&bond->lock);
 
 err_close:
+	slave_dev->priv_flags &= ~IFF_BONDING;
 	dev_close(slave_dev);
 
 err_unset_master:
-- 
1.8.1.4
