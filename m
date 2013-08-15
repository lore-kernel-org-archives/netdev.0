From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [patch 2/2] libceph: potential NULL dereference in
 ceph_osdc_handle_map()
Date: Thu, 15 Aug 2013 08:52:48 +0300
Message-ID: <20130815055248.GB23580@elgon.mountain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	ceph-devel@vger.kernel.org, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: Sage Weil <sage@inktank.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:39151 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753138Ab3HOFxG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Aug 2013 01:53:06 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There are two places where we read "nr_maps" if both of them are set to
zero then we would hit a NULL dereference here.

Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
---
I think this is a real bug, but please review my fix for it because I'm
not very familiar with this code.

diff --git a/net/ceph/osd_client.c b/net/ceph/osd_client.c
index 559a832..56f1fe5 100644
--- a/net/ceph/osd_client.c
+++ b/net/ceph/osd_client.c
@@ -1786,6 +1786,8 @@ void ceph_osdc_handle_map(struct ceph_osd_client *osdc, struct ceph_msg *msg)
 		nr_maps--;
 	}
 
+	if (!osdc->osdmap)
+		goto bad;
 done:
 	downgrade_write(&osdc->map_sem);
 	ceph_monc_got_osdmap(&osdc->client->monc, osdc->osdmap->epoch);
