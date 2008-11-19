From: Patrick McHardy <kaber@trash.net>
Subject: netlink: avoid memset of 0 bytes sparse warning
Date: Wed, 19 Nov 2008 14:56:12 +0100
Message-ID: <49241AFC.5030705@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------000801040807000502010903"
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:64410 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752394AbYKSN4S (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Nov 2008 08:56:18 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------000801040807000502010903
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit


--------------000801040807000502010903
Content-Type: text/x-patch;
 name="01.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="01.diff"

commit d30196c4cab8442451794d25a8d8a072dadca2eb
Author: Patrick McHardy <kaber@trash.net>
Date:   Wed Nov 19 14:55:11 2008 +0100

    netlink: avoid memset of 0 bytes sparse warning
    
    A netlink attribute padding of zero triggers this sparse warning:
    
    include/linux/netlink.h:245:8: warning: memset with byte count of 0
    
    Avoid the memset when the size parameter is constant and requires no padding.
    
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/include/linux/netlink.h b/include/linux/netlink.h
index 9ff1b54..51b09a1 100644
--- a/include/linux/netlink.h
+++ b/include/linux/netlink.h
@@ -242,7 +242,8 @@ __nlmsg_put(struct sk_buff *skb, u32 pid, u32 seq, int type, int len, int flags)
 	nlh->nlmsg_flags = flags;
 	nlh->nlmsg_pid = pid;
 	nlh->nlmsg_seq = seq;
-	memset(NLMSG_DATA(nlh) + len, 0, NLMSG_ALIGN(size) - size);
+	if (!__builtin_constant_p(size) || NLMSG_ALIGN(size) - size != 0)
+		memset(NLMSG_DATA(nlh) + len, 0, NLMSG_ALIGN(size) - size);
 	return nlh;
 }
 

--------------000801040807000502010903--
