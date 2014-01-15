From: Wang Weidong <wangweidong1@huawei.com>
Subject: [PATCH net-next] sctp: create helper function to enable|disable sackdelay
Date: Wed, 15 Jan 2014 17:24:01 +0800
Message-ID: <52D653B1.4040708@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <linux-sctp@vger.kernel.org>, <netdev@vger.kernel.org>
To: Vlad Yasevich <vyasevich@gmail.com>,
	Neil Horman <nhorman@tuxdriver.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:52266 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751037AbaAOJZn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Jan 2014 04:25:43 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

add sctp_spp_sackdelay_{enable|disable} helper function for
avoiding code duplication. 

Signed-off-by: Wang Weidong <wangweidong1@huawei.com>
---
 net/sctp/socket.c | 37 +++++++++++++++++++------------------
 1 file changed, 19 insertions(+), 18 deletions(-)

diff --git a/net/sctp/socket.c b/net/sctp/socket.c
index 7cc62b9..20dd417 100644
--- a/net/sctp/socket.c
+++ b/net/sctp/socket.c
@@ -2527,6 +2527,16 @@ static int sctp_setsockopt_peer_addr_params(struct sock *sk,
 	return 0;
 }
 
+static inline __u32 sctp_spp_sackdelay_enable(__u32 param_flags)
+{
+	return (param_flags & ~SPP_SACKDELAY) | SPP_SACKDELAY_ENABLE;
+}
+
+static inline __u32 sctp_spp_sackdelay_disable(__u32 param_flags)
+{
+	return (param_flags & ~SPP_SACKDELAY) | SPP_SACKDELAY_DISABLE;
+}
+
 /*
  * 7.1.23.  Get or set delayed ack timer (SCTP_DELAYED_SACK)
  *
@@ -2610,37 +2620,31 @@ static int sctp_setsockopt_delayed_ack(struct sock *sk,
 			asoc->sackdelay =
 				msecs_to_jiffies(params.sack_delay);
 			asoc->param_flags =
-				(asoc->param_flags & ~SPP_SACKDELAY) |
-				SPP_SACKDELAY_ENABLE;
+				sctp_spp_sackdelay_enable(asoc->param_flags);
 		} else {
 			sp->sackdelay = params.sack_delay;
 			sp->param_flags =
-				(sp->param_flags & ~SPP_SACKDELAY) |
-				SPP_SACKDELAY_ENABLE;
+				sctp_spp_sackdelay_enable(sp->param_flags);
 		}
 	}
 
 	if (params.sack_freq == 1) {
 		if (asoc) {
 			asoc->param_flags =
-				(asoc->param_flags & ~SPP_SACKDELAY) |
-				SPP_SACKDELAY_DISABLE;
+				sctp_spp_sackdelay_disable(asoc->param_flags);
 		} else {
 			sp->param_flags =
-				(sp->param_flags & ~SPP_SACKDELAY) |
-				SPP_SACKDELAY_DISABLE;
+				sctp_spp_sackdelay_disable(sp->param_flags);
 		}
 	} else if (params.sack_freq > 1) {
 		if (asoc) {
 			asoc->sackfreq = params.sack_freq;
 			asoc->param_flags =
-				(asoc->param_flags & ~SPP_SACKDELAY) |
-				SPP_SACKDELAY_ENABLE;
+				sctp_spp_sackdelay_enable(asoc->param_flags);
 		} else {
 			sp->sackfreq = params.sack_freq;
 			sp->param_flags =
-				(sp->param_flags & ~SPP_SACKDELAY) |
-				SPP_SACKDELAY_ENABLE;
+				sctp_spp_sackdelay_enable(sp->param_flags);
 		}
 	}
 
@@ -2652,18 +2656,15 @@ static int sctp_setsockopt_delayed_ack(struct sock *sk,
 				trans->sackdelay =
 					msecs_to_jiffies(params.sack_delay);
 				trans->param_flags =
-					(trans->param_flags & ~SPP_SACKDELAY) |
-					SPP_SACKDELAY_ENABLE;
+					sctp_spp_sackdelay_enable(trans->param_flags);
 			}
 			if (params.sack_freq == 1) {
 				trans->param_flags =
-					(trans->param_flags & ~SPP_SACKDELAY) |
-					SPP_SACKDELAY_DISABLE;
+					sctp_spp_sackdelay_disable(trans->param_flags);
 			} else if (params.sack_freq > 1) {
 				trans->sackfreq = params.sack_freq;
 				trans->param_flags =
-					(trans->param_flags & ~SPP_SACKDELAY) |
-					SPP_SACKDELAY_ENABLE;
+					sctp_spp_sackdelay_enable(trans->param_flags);
 			}
 		}
 	}
-- 
1.7.12
