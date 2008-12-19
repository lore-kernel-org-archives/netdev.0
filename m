From: James Morris <jmorris@namei.org>
Subject: [PATCH 3/3][RFC] SELinux: don't check permissions for kernel
 mounts
Date: Fri, 19 Dec 2008 12:07:19 +1100 (EST)
Message-ID: <alpine.LRH.1.10.0812191206380.4137@tundra.namei.org>
References: <49381644.8020502@intel.com>  <20081204175236.GA19808@x200.localdomain>  <1228414280.11091.54.camel@moss-spartans.epoch.ncsc.mil>  <20081204.102138.123959105.davem@davemloft.net>  <1228419142.11091.90.camel@moss-spartans.epoch.ncsc.mil>
 <1228421219.11091.94.camel@moss-spartans.epoch.ncsc.mil>  <m1bpvrslk0.fsf@frodo.ebiederm.org>  <1228486339.20274.3.camel@localhost.localdomain>  <alpine.LRH.1.10.0812112139340.25553@tundra.namei.org>  <20081212052420.GA14948@x200.localdomain>
 <alpine.LRH.1.10.0812122022520.32426@tundra.namei.org> <1229117086.3134.22.camel@localhost.localdomain> <alpine.LRH.1.10.0812160021030.10723@tundra.namei.org> <alpine.LRH.1.10.0812191144370.4137@tundra.namei.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Alexey Dobriyan <adobriyan@gmail.com>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	David Miller <davem@davemloft.net>, auke-jan.h.kok@intel.com,
	Andrew Morton <akpm@linux-foundation.org>,
	e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	Eric Paris <eparis@parisplace.org>,
	Stephen Smalley <sds@tycho.nsa.gov>,
	Al Viro <viro@ftp.linux.org.uk>,
	Chris Wright <chrisw@sous-sol.org>
To: linux-security-module@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from tundra.namei.org ([65.99.196.166]:4795 "EHLO tundra.namei.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752142AbYLSBIL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Dec 2008 20:08:11 -0500
In-Reply-To: <alpine.LRH.1.10.0812191144370.4137@tundra.namei.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Don't bother checking permissions when the kernel performs an internal 
mount, as this should always be allowed.

Signed-off-by: James Morris <jmorris@namei.org>
---
 security/selinux/hooks.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/security/selinux/hooks.c b/security/selinux/hooks.c
index 3897758..4a44903 100644
--- a/security/selinux/hooks.c
+++ b/security/selinux/hooks.c
@@ -2461,6 +2461,10 @@ static int selinux_sb_kern_mount(struct super_block *sb, int flags, void *data)
 	if (rc)
 		return rc;
 
+	/* Allow all mounts performed by the kernel */
+	if (flags & MS_KERNMOUNT)
+		return 0;
+
 	AVC_AUDIT_DATA_INIT(&ad, FS);
 	ad.u.fs.path.dentry = sb->s_root;
 	return superblock_has_perm(current, sb, FILESYSTEM__MOUNT, &ad);
-- 
1.6.0.4

