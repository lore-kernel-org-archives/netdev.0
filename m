From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH 1/2] sysfs: sysfs_delete_link handle symlinks from untagged to tagged directories.
Date: Tue, 20 Jul 2010 22:10:58 -0700
Message-ID: <m1vd894dy5.fsf_-_@fess.ebiederm.org>
References: <20100621222938.GA20583@suse.de>
	<m1eig0dmhk.fsf@fess.ebiederm.org> <20100621231058.GA1066@suse.de>
	<m14ogwc4ou.fsf@fess.ebiederm.org> <20100622035631.GA3755@suse.de>
	<m1630q7x5v.fsf_-_@fess.ebiederm.org>
	<20100708211930.GA15385@kroah.com> <m1r5jdbobe.fsf@fess.ebiederm.org>
	<20100708230601.GB17002@kroah.com>
	<20100719133451.0862ca62.akpm@linux-foundation.org>
	<20100720201334.GA11991@suse.de> <m139vd5sms.fsf_-_@fess.ebiederm.org>
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
Received: from out01.mta.xmission.com ([166.70.13.231]:33464 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751200Ab0GUFLE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Jul 2010 01:11:04 -0400
In-Reply-To: <m139vd5sms.fsf_-_@fess.ebiederm.org> (Eric W. Biederman's message of "Tue\, 20 Jul 2010 22\:08\:27 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This happens for network devices when SYSFS_DEPRECATED is enabled.

Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
---
 fs/sysfs/symlink.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/fs/sysfs/symlink.c b/fs/sysfs/symlink.c
index 44bca5f..6603833 100644
--- a/fs/sysfs/symlink.c
+++ b/fs/sysfs/symlink.c
@@ -135,7 +135,7 @@ void sysfs_delete_link(struct kobject *kobj, struct kobject *targ,
 {
 	const void *ns = NULL;
 	spin_lock(&sysfs_assoc_lock);
-	if (targ->sd)
+	if (targ->sd && sysfs_ns_type(kobj->sd))
 		ns = targ->sd->s_ns;
 	spin_unlock(&sysfs_assoc_lock);
 	sysfs_hash_and_remove(kobj->sd, ns, name);
-- 
1.6.5.2.143.g8cc62

