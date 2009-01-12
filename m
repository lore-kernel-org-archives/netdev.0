From: Patrick McHardy <kaber@trash.net>
Subject: netfilter 09/09: remove padding from struct xt_match on 64bit builds
Date: Mon, 12 Jan 2009 11:06:11 +0100 (MET)
Message-ID: <20090112100611.9280.87597.sendpatchset@x2.localnet>
References: <20090112100559.9280.23431.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20090112100559.9280.23431.sendpatchset@x2.localnet>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

commit 269e837197ecee6b37ed3d83b1ddc582f6a53947
Author: Richard Kennedy <richard@rsk.demon.co.uk>
Date:   Mon Jan 12 10:52:48 2009 +0100

    netfilter: remove padding from struct xt_match on 64bit builds
    
    reorder struct xt_match to remove 8 bytes of padding and make its size
    128 bytes.
    
    This saves a small amount of data space in each of the xt netfilter
    modules and fits xt_match in one 128 byte cache line.
    
    Signed-off-by: Richard Kennedy <richard@rsk.demon.co.uk>
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/include/linux/netfilter/x_tables.h b/include/linux/netfilter/x_tables.h
index e52ce47..c7ee874 100644
--- a/include/linux/netfilter/x_tables.h
+++ b/include/linux/netfilter/x_tables.h
@@ -270,6 +270,7 @@ struct xt_match
 	struct list_head list;
 
 	const char name[XT_FUNCTION_MAXNAMELEN-1];
+	u_int8_t revision;
 
 	/* Return true or false: return FALSE and set *hotdrop = 1 to
            force immediate packet drop. */
@@ -302,7 +303,6 @@ struct xt_match
 	unsigned short proto;
 
 	unsigned short family;
-	u_int8_t revision;
 };
 
 /* Registration hooks for targets. */
