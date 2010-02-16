From: Patrick McHardy <kaber@trash.net>
Subject: netfilter 60/62: ebtables: abort if next_offset is too small
Date: Tue, 16 Feb 2010 15:56:41 +0100 (MET)
Message-ID: <20100216145639.2796.91630.sendpatchset@x2.localnet>
References: <20100216145517.2796.40634.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20100216145517.2796.40634.sendpatchset@x2.localnet>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

commit 1756de262e41112a8a8927808eb2f03d21fd4786
Author: Florian Westphal <fwestphal@astaro.com>
Date:   Mon Feb 15 18:15:55 2010 +0100

    netfilter: ebtables: abort if next_offset is too small
    
    next_offset must be > 0, otherwise this loops forever.
    The offset also contains the size of the ebt_entry structure
    itself, so anything smaller is invalid.
    
    Signed-off-by: Florian Westphal <fwestphal@astaro.com>
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/net/bridge/netfilter/ebtables.c b/net/bridge/netfilter/ebtables.c
index bcdf02d..4370e96 100644
--- a/net/bridge/netfilter/ebtables.c
+++ b/net/bridge/netfilter/ebtables.c
@@ -444,6 +444,8 @@ static int ebt_verify_pointers(const struct ebt_replace *repl,
 				break;
 			if (left < e->next_offset)
 				break;
+			if (e->next_offset < sizeof(struct ebt_entry))
+				return -EINVAL;
 			offset += e->next_offset;
 		}
 	}
