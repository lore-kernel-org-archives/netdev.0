From: Patrick McHardy <kaber@trash.net>
Subject: netfilter 50/62: xt_recent: inform user when hitcount is too large
Date: Tue, 16 Feb 2010 15:56:27 +0100 (MET)
Message-ID: <20100216145625.2796.75470.sendpatchset@x2.localnet>
References: <20100216145517.2796.40634.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20100216145517.2796.40634.sendpatchset@x2.localnet>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

commit 98e6d2d5ee26bf56850a10eb64139c68fb09ba19
Author: Jan Engelhardt <jengelh@medozas.de>
Date:   Mon Feb 15 16:31:35 2010 +0100

    netfilter: xt_recent: inform user when hitcount is too large
    
    It is one of these things that iptables cannot catch and which can
    cause "Invalid argument" to be printed. Without a hint in dmesg, it is
    not going to be helpful.
    
    Signed-off-by: Jan Engelhardt <jengelh@medozas.de>
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/net/netfilter/xt_recent.c b/net/netfilter/xt_recent.c
index 2033331..132cfaa 100644
--- a/net/netfilter/xt_recent.c
+++ b/net/netfilter/xt_recent.c
@@ -53,7 +53,7 @@ module_param(ip_list_perms, uint, 0400);
 module_param(ip_list_uid, uint, 0400);
 module_param(ip_list_gid, uint, 0400);
 MODULE_PARM_DESC(ip_list_tot, "number of IPs to remember per list");
-MODULE_PARM_DESC(ip_pkt_list_tot, "number of packets per IP to remember (max. 255)");
+MODULE_PARM_DESC(ip_pkt_list_tot, "number of packets per IP address to remember (max. 255)");
 MODULE_PARM_DESC(ip_list_hash_size, "size of hash table used to look up IPs");
 MODULE_PARM_DESC(ip_list_perms, "permissions on /proc/net/xt_recent/* files");
 MODULE_PARM_DESC(ip_list_uid,"owner of /proc/net/xt_recent/* files");
@@ -306,8 +306,12 @@ static bool recent_mt_check(const struct xt_mtchk_param *par)
 	if ((info->check_set & (XT_RECENT_SET | XT_RECENT_REMOVE)) &&
 	    (info->seconds || info->hit_count))
 		return false;
-	if (info->hit_count > ip_pkt_list_tot)
+	if (info->hit_count > ip_pkt_list_tot) {
+		pr_info(KBUILD_MODNAME ": hitcount (%u) is larger than "
+			"packets to be remembered (%u)\n",
+			info->hit_count, ip_pkt_list_tot);
 		return false;
+	}
 	if (info->name[0] == '\0' ||
 	    strnlen(info->name, XT_RECENT_NAME_LEN) == XT_RECENT_NAME_LEN)
 		return false;
