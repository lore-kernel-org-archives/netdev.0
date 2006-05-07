From: James Morris <jmorris@namei.org>
Subject: [RFC][SECMARK 08/08] Add selinux_relabel_packet_permission() check
 to xt_SECMARK
Date: Sun, 7 May 2006 11:40:45 -0400 (EDT)
Message-ID: <Pine.LNX.4.64.0605071139330.8588@d.namei>
References: <Pine.LNX.4.64.0605071104590.8588@d.namei>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, netfilter-devel@lists.samba.org,
	Stephen Smalley <sds@tycho.nsa.gov>,
	Daniel J Walsh <dwalsh@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail7.sea5.speakeasy.net ([69.17.117.9]:31922 "EHLO
	mail7.sea5.speakeasy.net") by vger.kernel.org with ESMTP
	id S932185AbWEGPkz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 7 May 2006 11:40:55 -0400
To: selinux@tycho.nsa.gov
In-Reply-To: <Pine.LNX.4.64.0605071104590.8588@d.namei>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch adds the selinux_relabel_packet_permission() check to the 
SECMARK target, so that SELinux policy is consulted to ensure that the 
labeling operation is permitted by the current task.


Signed-off-by: James Morris <jmorris@namei.org>

---

 net/netfilter/xt_SECMARK.c |    6 ++++++
 1 file changed, 6 insertions(+)

diff -purN -X dontdiff linux-2.6.17-rc3-git7.p/net/netfilter/xt_SECMARK.c linux-2.6.17-rc3-git7.w/net/netfilter/xt_SECMARK.c
--- linux-2.6.17-rc3-git7.p/net/netfilter/xt_SECMARK.c	2006-05-03 11:34:12.000000000 -0400
+++ linux-2.6.17-rc3-git7.w/net/netfilter/xt_SECMARK.c	2006-05-07 00:35:44.000000000 -0400
@@ -72,6 +72,12 @@ static int checkentry_selinux(struct xt_
 		return 0;
 	}
 
+	err = selinux_relabel_packet_permission(sel->selsid);
+	if (err) {
+		printk(KERN_INFO PFX "unable to obtain relabeling permission\n");
+		return 0;
+	}
+
 	return 1;
 }
 
