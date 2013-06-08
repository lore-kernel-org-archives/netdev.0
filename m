From: Jason Wang <jasowang@redhat.com>
Subject: [net PATCH] tuntap: set SOCK_ZEROCOPY flag during open
Date: Sat,  8 Jun 2013 14:17:41 +0800
Message-ID: <1370672261-30076-1-git-send-email-jasowang@redhat.com>
Cc: Jason Wang <jasowang@redhat.com>
To: smtp.corp.redhat.com@redhat.com, davem@davemloft.net,
	mst@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:27721 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754660Ab3FKNMq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 11 Jun 2013 09:12:46 -0400
Received: from int-mx01.intmail.prod.int.phx2.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id r5BDCgB2008210
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Tue, 11 Jun 2013 09:12:46 -0400
Received: from redhat.com (vpn1-6-190.ams2.redhat.com [10.36.6.190])
	by int-mx01.intmail.prod.int.phx2.redhat.com (8.13.8/8.13.8) with SMTP id r5BDCf6k004749
	for <netdev@vger.kernel.org>; Tue, 11 Jun 2013 09:12:41 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 54f968d6efdbf7dec36faa44fc11f01b0e4d1990
(tuntap: move socket to tun_file) forgets to set SOCK_ZEROCOPY flag, which will
prevent vhost_net from doing zercopy w/ tap. This patch fixes this by setting
it during file open.

Cc: Michael S. Tsirkin <mst@redhat.com>
Signed-off-by: Jason Wang <jasowang@redhat.com>
---
 drivers/net/tun.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index f042b03..d2ddd6d 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -2155,6 +2155,8 @@ static int tun_chr_open(struct inode *inode, struct file * file)
 	set_bit(SOCK_EXTERNALLY_ALLOCATED, &tfile->socket.flags);
 	INIT_LIST_HEAD(&tfile->next);
 
+	sock_set_flag(&tfile->sk, SOCK_ZEROCOPY);
+
 	return 0;
 }
 
-- 
1.7.1
