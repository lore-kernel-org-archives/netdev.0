From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH 10/12] net: sctp: avoid incorrect time_t use
Date: Wed, 30 Sep 2015 13:26:40 +0200
Message-ID: <1443612402-3000775-11-git-send-email-arnd@arndb.de>
References: <1443612402-3000775-1-git-send-email-arnd@arndb.de>
Cc: y2038@lists.linaro.org, linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Arnd Bergmann <arnd@arndb.de>,
	Vlad Yasevich <vyasevich@gmail.com>,
	Neil Horman <nhorman@tuxdriver.com>, linux-sctp@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1443612402-3000775-1-git-send-email-arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

We want to avoid using time_t in the kernel because of the y2038
overflow problem. The use in sctp is not for storing seconds at
all, but instead uses microseconds and is passed as 32-bit
on all machines.

This patch changes the type to u32, which better fits the use.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
Cc: Vlad Yasevich <vyasevich@gmail.com>
Cc: Neil Horman <nhorman@tuxdriver.com>
Cc: linux-sctp@vger.kernel.org
---
 net/sctp/sm_make_chunk.c | 2 +-
 net/sctp/sm_statefuns.c  | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/sctp/sm_make_chunk.c b/net/sctp/sm_make_chunk.c
index 7954c52e1794..763e06a55155 100644
--- a/net/sctp/sm_make_chunk.c
+++ b/net/sctp/sm_make_chunk.c
@@ -2494,7 +2494,7 @@ static int sctp_process_param(struct sctp_association *asoc,
 	__u16 sat;
 	int retval = 1;
 	sctp_scope_t scope;
-	time_t stale;
+	u32 stale;
 	struct sctp_af *af;
 	union sctp_addr_param *addr_param;
 	struct sctp_transport *t;
diff --git a/net/sctp/sm_statefuns.c b/net/sctp/sm_statefuns.c
index d7eaa7354cf7..6f46aa16cb76 100644
--- a/net/sctp/sm_statefuns.c
+++ b/net/sctp/sm_statefuns.c
@@ -2306,7 +2306,7 @@ static sctp_disposition_t sctp_sf_do_5_2_6_stale(struct net *net,
 						 sctp_cmd_seq_t *commands)
 {
 	struct sctp_chunk *chunk = arg;
-	time_t stale;
+	u32 stale;
 	sctp_cookie_preserve_param_t bht;
 	sctp_errhdr_t *err;
 	struct sctp_chunk *reply;
-- 
2.1.0.rc2
