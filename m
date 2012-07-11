From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: [ethtool PATCH] ethtool: Resolve use of uninitialized memory in
	rxclass_get_dev_info
Date: Wed, 11 Jul 2012 14:16:17 -0700
Message-ID: <20120711211617.15016.12886.stgit@gitlad.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: bhutchings@solarflare.com, jeffrey.t.kirsher@intel.com,
	alexander.duyck@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:34077 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755076Ab2GKVP6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Jul 2012 17:15:58 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The ethtool function for getting the rule count was not zeroing out the
data field before passing it to the kernel.  As a result the value started
uninitialized and was incorrectly returning a result indicating that
devices supported setting new rule indexes.  In order to correct this I am
adding a one line fix that sets data to zero before we pass the command to
the kernel.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
---

 rxclass.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/rxclass.c b/rxclass.c
index 4d49aa6..e1633a8 100644
--- a/rxclass.c
+++ b/rxclass.c
@@ -207,6 +207,7 @@ static int rxclass_get_dev_info(struct cmd_context *ctx, __u32 *count,
 	int err;
 
 	nfccmd.cmd = ETHTOOL_GRXCLSRLCNT;
+	nfccmd.data = 0;
 	err = send_ioctl(ctx, &nfccmd);
 	*count = nfccmd.rule_cnt;
 	if (driver_select)
