From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH 5/6] tc_util: No need to terminate an snprintf'ed buffer
Date: Fri,  1 Sep 2017 18:52:55 +0200
Message-ID: <20170901165256.21459-6-phil@nwl.cc>
References: <20170901165256.21459-1-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:48805 "EHLO mail.nwl.cc"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752202AbdIAQxk (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 1 Sep 2017 12:53:40 -0400
In-Reply-To: <20170901165256.21459-1-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

snprintf() won't leave the buffer unterminated, so manually terminating
is not necessary here.

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 tc/tc_util.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/tc/tc_util.c b/tc/tc_util.c
index 371046839ba9f..50d355046bdad 100644
--- a/tc/tc_util.c
+++ b/tc/tc_util.c
@@ -434,7 +434,6 @@ static const char *action_n2a(int action)
 		return "trap";
 	default:
 		snprintf(buf, 64, "%d", action);
-		buf[63] = '\0';
 		return buf;
 	}
 }
-- 
2.13.1
