From: Patrick McHardy <kaber@trash.net>
Subject: netfilter 29/29: fix warning in net/netfilter/nf_conntrack_ftp.c
Date: Thu, 27 Nov 2008 17:15:42 +0100 (MET)
Message-ID: <20081127161542.13891.8102.sendpatchset@x2.localnet>
References: <20081127161503.13891.62766.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20081127161503.13891.62766.sendpatchset@x2.localnet>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

commit d6e8cc6cc7ac77b0f9118f78c453a2e834e62709
Author: Ingo Molnar <mingo@elte.hu>
Date:   Tue Nov 25 18:23:03 2008 +0100

    netfilter: fix warning in net/netfilter/nf_conntrack_ftp.c
    
    this warning:
    
      net/netfilter/nf_conntrack_ftp.c: In function 'help':
      net/netfilter/nf_conntrack_ftp.c:360: warning: 'matchoff' may be used uninitialized in this function
      net/netfilter/nf_conntrack_ftp.c:360: warning: 'matchlen' may be used uninitialized in this function
    
    triggers because GCC does not recognize the (correct) error flow
    between find_pattern(), 'found', 'matchoff' and 'matchlen'.
    
    Annotate it.
    
    Signed-off-by: Ingo Molnar <mingo@elte.hu>
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/net/netfilter/nf_conntrack_ftp.c b/net/netfilter/nf_conntrack_ftp.c
index 867cad6..00fecc3 100644
--- a/net/netfilter/nf_conntrack_ftp.c
+++ b/net/netfilter/nf_conntrack_ftp.c
@@ -358,7 +358,7 @@ static int help(struct sk_buff *skb,
 	int ret;
 	u32 seq;
 	int dir = CTINFO2DIR(ctinfo);
-	unsigned int matchlen, matchoff;
+	unsigned int uninitialized_var(matchlen), uninitialized_var(matchoff);
 	struct nf_ct_ftp_master *ct_ftp_info = &nfct_help(ct)->help.ct_ftp_info;
 	struct nf_conntrack_expect *exp;
 	union nf_inet_addr *daddr;
