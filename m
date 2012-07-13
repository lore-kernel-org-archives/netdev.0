From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: [ethtool PATCH] ethtool: Resolve use of uninitialized memory in
	rxclass_get_dev_info
Date: Fri, 13 Jul 2012 09:55:29 -0700
Message-ID: <20120713165221.28140.92681.stgit@gitlad.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: jeffrey.t.kirsher@intel.com
To: netdev@vger.kernel.org, bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:41699 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757109Ab2GMQzI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 13 Jul 2012 12:55:08 -0400
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

I am resending this since I didn't see any notification that it had been seen.
I also realized that I had not clearly identified that this is an ethtool user
space patch and not an ethtool kernel space patch.

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
