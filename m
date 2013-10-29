From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [patch] libertas: potential oops in debugfs
Date: Tue, 29 Oct 2013 22:06:41 +0300
Message-ID: <20131029190641.GB21820@longonot.mountain>
References: <20131025144452.GA28451@ngolde.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: libertas-dev@lists.infradead.org, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, security@kernel.org,
	Nico Golde <nico@ngolde.de>, Fabian Yamaguchi <fabs@goesec.de>
To: "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:24889 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751040Ab3J2TKY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Oct 2013 15:10:24 -0400
Content-Disposition: inline
In-Reply-To: <20131025144452.GA28451@ngolde.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If we do a zero size write then it will oops.  This can only be
triggered by root.

Reported-by: Nico Golde <nico@ngolde.de>
Reported-by: Fabian Yamaguchi <fabs@goesec.de>
Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

diff --git a/drivers/net/wireless/libertas/debugfs.c b/drivers/net/wireless/libertas/debugfs.c
index 668dd27..a148f14 100644
--- a/drivers/net/wireless/libertas/debugfs.c
+++ b/drivers/net/wireless/libertas/debugfs.c
@@ -913,6 +913,9 @@ static ssize_t lbs_debugfs_write(struct file *f, const char __user *buf,
 	char *p2;
 	struct debug_data *d = f->private_data;
 
+	if (cnt == 0)
+		return 0;
+
 	pdata = kmalloc(cnt, GFP_KERNEL);
 	if (pdata == NULL)
 		return 0;
