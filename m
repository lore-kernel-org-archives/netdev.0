From: Frank Pavlic <fpavlic@de.ibm.com>
Subject: [PATCH 1/5] s390: minor fix in cu3088
Date: Wed, 24 May 2006 09:51:05 +0200
Message-ID: <20060524095105.68a65118@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate3.de.ibm.com ([195.212.29.152]:31344 "EHLO
	mtagate3.de.ibm.com") by vger.kernel.org with ESMTP id S932646AbWEXHum
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 24 May 2006 03:50:42 -0400
Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate3.de.ibm.com (8.13.6/8.13.6) with ESMTP id k4O7ofSm165868
	for <netdev@vger.kernel.org>; Wed, 24 May 2006 07:50:41 GMT
Received: from d12av02.megacenter.de.ibm.com (d12av02.megacenter.de.ibm.com [9.149.165.228])
	by d12nrmr1607.megacenter.de.ibm.com (8.12.10/NCO/VER6.8) with ESMTP id k4O7qKkc153040
	for <netdev@vger.kernel.org>; Wed, 24 May 2006 09:52:20 +0200
Received: from d12av02.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av02.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k4O7ofpn028910
	for <netdev@vger.kernel.org>; Wed, 24 May 2006 09:50:41 +0200
To: jgarzik@pobox.com
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Jeff,
please apply following 5 patches. 

Thanks ...

Frank

From: Cornelia Huck <cornelia.huck@de.ibm.com>

In case of a parse error for the cu3088 group attribute,
return -EINVAL instead of count.

Signed-off-by: Frank Pavlic <fpavlic@de.ibm.com>
---

 drivers/s390/net/cu3088.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

99e5e7d1a3245f4416290a336bc9fc8107d05d5e
diff --git a/drivers/s390/net/cu3088.c b/drivers/s390/net/cu3088.c
index b125331..e1b8c9a 100644
--- a/drivers/s390/net/cu3088.c
+++ b/drivers/s390/net/cu3088.c
@@ -77,7 +77,7 @@ group_write(struct device_driver *drv, c
 		int len;
 
 		if (!(end = strchr(start, delim[i])))
-			return count;
+			return -EINVAL;
 		len = min_t(ptrdiff_t, BUS_ID_SIZE, end - start + 1);
 		strlcpy (bus_ids[i], start, len);
 		argv[i] = bus_ids[i];
-- 
1.2.4

