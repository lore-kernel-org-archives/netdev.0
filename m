From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: [PATCH 3/6] dlm: fix not reconnecting on connecting error handling
Date: Tue, 11 Aug 2015 19:22:22 -0300
Message-ID: <299da97baa88cdd50c77dd1683400c52c4769716.1439330654.git.marcelo.leitner@gmail.com>
References: <cover.1439330654.git.marcelo.leitner@gmail.com>
Cc: netdev@vger.kernel.org, Vlad Yasevich <vyasevich@gmail.com>,
	Neil Horman <nhorman@tuxdriver.com>,
	David Teigland <teigland@redhat.com>, tan.hu@zte.com.cn
To: cluster-devel@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:38711 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932675AbbHKWWp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 11 Aug 2015 18:22:45 -0400
In-Reply-To: <cover.1439330654.git.marcelo.leitner@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If we don't clear that bit, lowcomms_connect_sock() will not schedule
another attempt, and no further attempt will be done.

Signed-off-by: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
---
 fs/dlm/lowcomms.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/fs/dlm/lowcomms.c b/fs/dlm/lowcomms.c
index 749deb3b69b2932fb18e7ae70c06e4ced15bd9b6..54a0031067de3ae6d3cd0106d7b9d4e30c956cfd 100644
--- a/fs/dlm/lowcomms.c
+++ b/fs/dlm/lowcomms.c
@@ -1253,6 +1253,7 @@ out_err:
 			  con->retries, result);
 		mutex_unlock(&con->sock_mutex);
 		msleep(1000);
+		clear_bit(CF_CONNECT_PENDING, &con->flags);
 		lowcomms_connect_sock(con);
 		return;
 	}
-- 
2.4.3
