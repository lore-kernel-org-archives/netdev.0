From: Patrick McHardy <kaber@trash.net>
Subject: netfilter 03/06: nfnetlink_log: fix timeout handling
Date: Tue, 24 Feb 2009 15:52:47 +0100 (MET)
Message-ID: <20090224145247.9789.79931.sendpatchset@x2.localnet>
References: <20090224145243.9789.60678.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20090224145243.9789.60678.sendpatchset@x2.localnet>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

commit 2c6764b743f9d25dd0806a417f06920dcbd0f599
Author: Eric Leblond <eric@inl.fr>
Date:   Wed Feb 18 15:29:49 2009 +0100

    netfilter: nfnetlink_log: fix timeout handling
    
    NFLOG timeout was computed in timer by doing:
    
        flushtimeout*HZ/100
    
    Default value of flushtimeout was HZ (for 1 second delay). This was
    wrong for non 100HZ computer. This patch modify the default delay by
    using 100 instead of HZ.
    
    Signed-off-by: Eric Leblond <eric@inl.fr>
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/net/netfilter/nfnetlink_log.c b/net/netfilter/nfnetlink_log.c
index 580b837..c712e9f 100644
--- a/net/netfilter/nfnetlink_log.c
+++ b/net/netfilter/nfnetlink_log.c
@@ -39,7 +39,7 @@
 #endif
 
 #define NFULNL_NLBUFSIZ_DEFAULT	NLMSG_GOODSIZE
-#define NFULNL_TIMEOUT_DEFAULT 	HZ	/* every second */
+#define NFULNL_TIMEOUT_DEFAULT 	100	/* every second */
 #define NFULNL_QTHRESH_DEFAULT 	100	/* 100 packets */
 #define NFULNL_COPY_RANGE_MAX	0xFFFF	/* max packet size is limited by 16-bit struct nfattr nfa_len field */
 
