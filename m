From: Patrick McHardy <kaber@trash.net>
Subject: netfilter 24/29: nf_conntrack_proto_sctp: avoid bogus warning
Date: Thu, 27 Nov 2008 17:15:35 +0100 (MET)
Message-ID: <20081127161535.13891.23844.sendpatchset@x2.localnet>
References: <20081127161503.13891.62766.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20081127161503.13891.62766.sendpatchset@x2.localnet>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

commit 328bd8997dbb7184d5389e45c642af44ae6e9043
Author: Patrick McHardy <kaber@trash.net>
Date:   Mon Nov 24 13:44:55 2008 +0100

    netfilter: nf_conntrack_proto_sctp: avoid bogus warning
    
    net/netfilter/nf_conntrack_proto_sctp.c: In function 'sctp_packet':
    net/netfilter/nf_conntrack_proto_sctp.c:376: warning: array subscript is above array bounds
    
    gcc doesn't realize that do_basic_checks() guarantees that there is
    at least one valid chunk and thus new_state is never SCTP_CONNTRACK_MAX
    after the loop. Initialize to SCTP_CONNTRACK_NONE to avoid the warning.
    
    Based on patch by Wu Fengguang <wfg@linux.intel.com>
    
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/net/netfilter/nf_conntrack_proto_sctp.c b/net/netfilter/nf_conntrack_proto_sctp.c
index c2bd457..74e0379 100644
--- a/net/netfilter/nf_conntrack_proto_sctp.c
+++ b/net/netfilter/nf_conntrack_proto_sctp.c
@@ -317,7 +317,7 @@ static int sctp_packet(struct nf_conn *ct,
 		goto out;
 	}
 
-	old_state = new_state = SCTP_CONNTRACK_MAX;
+	old_state = new_state = SCTP_CONNTRACK_NONE;
 	write_lock_bh(&sctp_lock);
 	for_each_sctp_chunk (skb, sch, _sch, offset, dataoff, count) {
 		/* Special cases of Verification tag check (Sec 8.5.1) */
