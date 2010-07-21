From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH 2/2] sysfs: allow creating symlinks from untagged to tagged directories
Date: Tue, 20 Jul 2010 22:12:01 -0700
Message-ID: <m1r5ix4dwe.fsf_-_@fess.ebiederm.org>
References: <20100621222938.GA20583@suse.de>
	<m1eig0dmhk.fsf@fess.ebiederm.org> <20100621231058.GA1066@suse.de>
	<m14ogwc4ou.fsf@fess.ebiederm.org> <20100622035631.GA3755@suse.de>
	<m1630q7x5v.fsf_-_@fess.ebiederm.org>
	<20100708211930.GA15385@kroah.com> <m1r5jdbobe.fsf@fess.ebiederm.org>
	<20100708230601.GB17002@kroah.com>
	<20100719133451.0862ca62.akpm@linux-foundation.org>
	<20100720201334.GA11991@suse.de> <m139vd5sms.fsf_-_@fess.ebiederm.org>
	<m1vd894dy5.fsf_-_@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Greg KH <greg@kroah.com>, "Rafael J. Wysocki" <rjw@sisk.pl>,
	"Maciej W. Rozycki" <macro@linux-mips.org>,
	Kay Sievers <kay.sievers@vrfy.org>,
	Johannes Berg <johannes@sipsolutions.net>,
	netdev <netdev@vger.kernel.org>
To: Greg KH <gregkh@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:33497 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1762114Ab0GUFMF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Jul 2010 01:12:05 -0400
In-Reply-To: <m1vd894dy5.fsf_-_@fess.ebiederm.org> (Eric W. Biederman's message of "Tue\, 20 Jul 2010 22\:10\:58 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Supporting symlinks from untagged to tagged directories is reasonable,
and needed to support CONFIG_SYSFS_DEPRECATED.  So don't fail a prior
allowing that case to work.

Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
---
 fs/sysfs/symlink.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/fs/sysfs/symlink.c b/fs/sysfs/symlink.c
index 6603833..a7ac78f 100644
--- a/fs/sysfs/symlink.c
+++ b/fs/sysfs/symlink.c
@@ -67,7 +67,8 @@ static int sysfs_do_create_link(struct kobject *kobj, struct kobject *target,
 
 	sysfs_addrm_start(&acxt, parent_sd);
 	/* Symlinks must be between directories with the same ns_type */
-	if (ns_type == sysfs_ns_type(sd->s_symlink.target_sd->s_parent)) {
+	if (!ns_type ||
+	    (ns_type == sysfs_ns_type(sd->s_symlink.target_sd->s_parent))) {
 		if (warn)
 			error = sysfs_add_one(&acxt, sd);
 		else
-- 
1.6.5.2.143.g8cc62

