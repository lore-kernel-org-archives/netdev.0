From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [patch net-next] sctp: fix some debug output
Date: Tue, 24 Jan 2017 12:05:40 +0300
Message-ID: <20170124090540.GA27652@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Neil Horman <nhorman@tuxdriver.com>,
        "David S. Miller" <davem@davemloft.net>,
        linux-sctp@vger.kernel.org, netdev@vger.kernel.org,
        kernel-janitors@vger.kernel.org
To: Vlad Yasevich <vyasevich@gmail.com>,
        Xin Long <lucien.xin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:42508 "EHLO
        aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750710AbdAXJHD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 24 Jan 2017 04:07:03 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We added SCTP_EVENT_TIMEOUT_RECONF but we didn't update this array so
it causes an off-by-one read overflow.

Fixes: 7b9438de0cd4 ("sctp: add stream reconf timer")
Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

diff --git a/net/sctp/debug.c b/net/sctp/debug.c
index 95d7b15dad21..c5f4ed5242ac 100644
--- a/net/sctp/debug.c
+++ b/net/sctp/debug.c
@@ -159,6 +159,7 @@ static const char *const sctp_timer_tbl[] = {
 	"TIMEOUT_T4_RTO",
 	"TIMEOUT_T5_SHUTDOWN_GUARD",
 	"TIMEOUT_HEARTBEAT",
+	"TIMEOUT_RECONF",
 	"TIMEOUT_SACK",
 	"TIMEOUT_AUTOCLOSE",
 };
