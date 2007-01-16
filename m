From: "Eric W. Biederman" <ebiederm@xmission.com>
Subject: [PATCH 53/59] sysctl: Remove support for CTL_ANY
Date: Tue, 16 Jan 2007 09:39:58 -0700
Message-ID: <11689656972739-git-send-email-ebiederm@xmission.com>
References: <m1ac0jc4no.fsf@ebiederm.dsl.xmission.com>
Cc: <linux-kernel@vger.kernel.org>, <containers@lists.osdl.org>,
	<netdev@vger.kernel.org>, xfs-masters@oss.sgi.com, xfs@oss.sgi.com,
	linux-scsi@vger.kernel.org, James.Bottomley@SteelEye.com,
	minyard@acm.org, openipmi-developer@lists.sourceforge.net,
	<tony.luck@intel.com>, linux-mips@linux-mips.org,
	ralf@linux-mips.org, schwidefsky@de.ibm.com,
	heiko.carstens@de.ibm.com, linux390@de.ibm.com,
	linux-390@vm.marist.edu, paulus@samba.org, linuxppc-dev@ozlabs.org,
	lethal@linux-sh.org, linuxsh-shmedia-dev@lists.sourceforge.net,
	<ak@suse.de>, vojtech@suse.cz, clemens@ladisch.de,
	a.zummo@towertech.it, rtc-linux@googlegroups.com,
	linux-parport@lists.infradead.org, andrea@suse.de,
	tim@cyberelk.net, philb@gnu.org, aharkes@cs.cmu.edu,
	coda@cs.cmu.edu, codalist@TELEMANN.coda.cs.cmu.edu,
	aia21@cantab.net, linux-ntfs-dev@lists.sourceforge.net,
	mark.fasheh@oracle.com, kurt.hackel@oracle.com,
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751562AbXAPQqH@vger.kernel.org>
To: "<Andrew Morton" <akpm@osdl.org>
In-Reply-To: <m1ac0jc4no.fsf@ebiederm.dsl.xmission.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric W. Biederman <ebiederm@xmission.com> - unquoted

There are currently no users in the kernel for CTL_ANY and it
only has effect on the binary interface which is practically
unused.

So this complicates sysctl lookups for no good reason so just remove it.

Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
---
 include/linux/sysctl.h |    1 -
 kernel/sysctl.c        |    2 +-
 2 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/include/linux/sysctl.h b/include/linux/sysctl.h
index 63e1bac..c99e4bb 100644
--- a/include/linux/sysctl.h
+++ b/include/linux/sysctl.h
@@ -53,7 +53,6 @@ struct __sysctl_args {
 
 /* For internal pattern-matching use only: */
 #ifdef __KERNEL__
-#define CTL_ANY		-1	/* Matches any name */
 #define CTL_NONE	0
 #define CTL_UNNUMBERED	CTL_NONE	/* sysctl without a binary number */
 #endif
diff --git a/kernel/sysctl.c b/kernel/sysctl.c
index 8da6647..e655b11 100644
--- a/kernel/sysctl.c
+++ b/kernel/sysctl.c
@@ -1166,7 +1166,7 @@ repeat:
 	for ( ; table->ctl_name || table->procname; table++) {
 		if (!table->ctl_name)
 			continue;
-		if (n == table->ctl_name || table->ctl_name == CTL_ANY) {
+		if (n == table->ctl_name) {
 			int error;
 			if (table->child) {
 				if (ctl_perm(table, 001))
-- 
1.4.4.1.g278f
