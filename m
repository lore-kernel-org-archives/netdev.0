From: Arnaldo Carvalho de Melo <acme@redhat.com>
Subject: [PATCH 05/12] [DCCP]: Collapse repeated `len' statements into one
Date: Thu, 13 Dec 2007 13:05:58 -0200
Message-ID: <1197558365-31134-6-git-send-email-acme@redhat.com>
References: <1197558365-31134-1-git-send-email-acme@redhat.com>
 <1197558365-31134-2-git-send-email-acme@redhat.com>
 <1197558365-31134-3-git-send-email-acme@redhat.com>
 <1197558365-31134-4-git-send-email-acme@redhat.com>
 <1197558365-31134-5-git-send-email-acme@redhat.com>
Cc: netdev@vger.kernel.org, dccp@vger.kernel.org,
	Gerrit Renker <gerrit@erg.abdn.ac.uk>,
	Ian McDonald <ian.mcdonald@jandi.co.nz>,
	Arnaldo Carvalho de Melo <acme@redhat.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from an-out-0708.google.com ([209.85.132.242]:3622 "EHLO
	an-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761817AbXLMPGV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Dec 2007 10:06:21 -0500
Received: by an-out-0708.google.com with SMTP id d31so185722and.103
        for <netdev@vger.kernel.org>; Thu, 13 Dec 2007 07:06:20 -0800 (PST)
In-Reply-To: <1197558365-31134-5-git-send-email-acme@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gerrit Renker <gerrit@erg.abdn.ac.uk>

This replaces 4 individual assignments for `len' with a single
one, placed where the control flow of those 4 leads to.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Signed-off-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
Signed-off-by: Arnaldo Carvalho de Melo <acme@redhat.com>
---
 net/dccp/proto.c |    5 +----
 1 files changed, 1 insertions(+), 4 deletions(-)

diff --git a/net/dccp/proto.c b/net/dccp/proto.c
index cc87c50..0bed4a6 100644
--- a/net/dccp/proto.c
+++ b/net/dccp/proto.c
@@ -657,19 +657,15 @@ static int do_dccp_getsockopt(struct sock *sk, int level, int optname,
 					       (__be32 __user *)optval, optlen);
 	case DCCP_SOCKOPT_GET_CUR_MPS:
 		val = dp->dccps_mss_cache;
-		len = sizeof(val);
 		break;
 	case DCCP_SOCKOPT_SERVER_TIMEWAIT:
 		val = dp->dccps_server_timewait;
-		len = sizeof(val);
 		break;
 	case DCCP_SOCKOPT_SEND_CSCOV:
 		val = dp->dccps_pcslen;
-		len = sizeof(val);
 		break;
 	case DCCP_SOCKOPT_RECV_CSCOV:
 		val = dp->dccps_pcrlen;
-		len = sizeof(val);
 		break;
 	case 128 ... 191:
 		return ccid_hc_rx_getsockopt(dp->dccps_hc_rx_ccid, sk, optname,
@@ -681,6 +677,7 @@ static int do_dccp_getsockopt(struct sock *sk, int level, int optname,
 		return -ENOPROTOOPT;
 	}
 
+	len = sizeof(val);
 	if (put_user(len, optlen) || copy_to_user(optval, &val, len))
 		return -EFAULT;
 
-- 
1.5.3.4

