From: Simon Horman <horms@verge.net.au>
Subject: [patch] netfilter: default to NF_DROP in sip_help_tcp()
Date: Sat, 10 Jul 2010 12:16:04 +0900
Message-ID: <20100710031604.GA26990@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>
To: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I initially noticed this because of the compiler warning below, but it does
seem to be a valid concern in the case where ct_sip_get_header() returns 0
in the first iteration of the while loop.

net/netfilter/nf_conntrack_sip.c: In function 'sip_help_tcp':
net/netfilter/nf_conntrack_sip.c:1379: warning: 'ret' may be used uninitialized in this function

Signed-off-by: Simon Horman <horms@verge.net.au>

Index: nf-next-2.6/net/netfilter/nf_conntrack_sip.c
===================================================================
--- nf-next-2.6.orig/net/netfilter/nf_conntrack_sip.c	2010-07-10 12:11:52.000000000 +0900
+++ nf-next-2.6/net/netfilter/nf_conntrack_sip.c	2010-07-10 12:11:57.000000000 +0900
@@ -1376,7 +1376,7 @@ static int sip_help_tcp(struct sk_buff *
 	unsigned int msglen, origlen;
 	const char *dptr, *end;
 	s16 diff, tdiff = 0;
-	int ret;
+	int ret = NF_DROP;
 	typeof(nf_nat_sip_seq_adjust_hook) nf_nat_sip_seq_adjust;
 
 	if (ctinfo != IP_CT_ESTABLISHED &&
