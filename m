From: Patrick McHardy <kaber@trash.net>
Subject: netfilter 08/09: xt_time: print timezone for user information
Date: Mon, 12 Jan 2009 11:06:10 +0100 (MET)
Message-ID: <20090112100610.9280.48102.sendpatchset@x2.localnet>
References: <20090112100559.9280.23431.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20090112100559.9280.23431.sendpatchset@x2.localnet>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

commit 0fd565aa7fdb2dc88c65b16a4e2260d4abd5b027
Author: Jan Engelhardt <jengelh@medozas.de>
Date:   Mon Jan 12 10:51:56 2009 +0100

    netfilter: xt_time: print timezone for user information
    
    Let users have a way to figure out if their distro set the kernel
    timezone at all.
    
    Signed-off-by: Jan Engelhardt <jengelh@medozas.de>
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/net/netfilter/xt_time.c b/net/netfilter/xt_time.c
index 29375ba..93acaa5 100644
--- a/net/netfilter/xt_time.c
+++ b/net/netfilter/xt_time.c
@@ -243,6 +243,17 @@ static struct xt_match xt_time_mt_reg __read_mostly = {
 
 static int __init time_mt_init(void)
 {
+	int minutes = sys_tz.tz_minuteswest;
+
+	if (minutes < 0) /* east of Greenwich */
+		printk(KERN_INFO KBUILD_MODNAME
+		       ": kernel timezone is +%02d%02d\n",
+		       -minutes / 60, -minutes % 60);
+	else /* west of Greenwich */
+		printk(KERN_INFO KBUILD_MODNAME
+		       ": kernel timezone is -%02d%02d\n",
+		       minutes / 60, minutes % 60);
+
 	return xt_register_match(&xt_time_mt_reg);
 }
 
