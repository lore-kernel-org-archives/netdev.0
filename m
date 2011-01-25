From: Jiri Pirko <jpirko@redhat.com>
Subject: [PATCH net-next-2.6] bonding: fix return value of couple of store
 functions
Date: Tue, 25 Jan 2011 22:03:25 +0100
Message-ID: <20110125210324.GD2932@psychotron.redhat.com>
References: <20110125185315.GB2932@psychotron.redhat.com>
 <29198.1295983370@death>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:29314 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753334Ab1AYVDg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 25 Jan 2011 16:03:36 -0500
Content-Disposition: inline
In-Reply-To: <29198.1295983370@death>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

count is incorrectly returned even in case of fail. Return ret instead.

Signed-off-by: Jiri Pirko <jpirko@redhat.com>

diff --git a/drivers/net/bonding/bond_sysfs.c b/drivers/net/bonding/bond_sysfs.c
index 8fd0174..72bb0f6 100644
--- a/drivers/net/bonding/bond_sysfs.c
+++ b/drivers/net/bonding/bond_sysfs.c
@@ -1198,7 +1198,7 @@ static ssize_t bonding_store_carrier(struct device *d,
 			bond->dev->name, new_value);
 	}
 out:
-	return count;
+	return ret;
 }
 static DEVICE_ATTR(use_carrier, S_IRUGO | S_IWUSR,
 		   bonding_show_carrier, bonding_store_carrier);
@@ -1595,7 +1595,7 @@ static ssize_t bonding_store_slaves_active(struct device *d,
 		}
 	}
 out:
-	return count;
+	return ret;
 }
 static DEVICE_ATTR(all_slaves_active, S_IRUGO | S_IWUSR,
 		   bonding_show_slaves_active, bonding_store_slaves_active);
