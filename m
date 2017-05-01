From: SF Markus Elfring <elfring@users.sourceforge.net>
Subject: [PATCH 2/3] sctp: Combine two seq_printf() calls into one call in
 sctp_remaddr_seq_show()
Date: Mon, 1 May 2017 15:32:31 +0200
Message-ID: <856b4c28-d620-38cd-a442-f2fcafd42034@users.sourceforge.net>
References: <ea9206ca-2a2f-095e-d764-3f819610d5e8@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>,
        kernel-janitors@vger.kernel.org
To: linux-sctp@vger.kernel.org, netdev@vger.kernel.org,
        "David S. Miller" <davem@davemloft.net>,
        Neil Horman <nhorman@tuxdriver.com>,
        Vlad Yasevich <vyasevich@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.web.de ([212.227.15.14]:58502 "EHLO mout.web.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S2997394AbdEANdh (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 1 May 2017 09:33:37 -0400
In-Reply-To: <ea9206ca-2a2f-095e-d764-3f819610d5e8@users.sourceforge.net>
Content-Language: en-GB
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Markus Elfring <elfring@users.sourceforge.net>
Date: Mon, 1 May 2017 14:24:34 +0200

A bit of data was put into a sequence by two separate function calls.
Print the same data by a single function call instead.

This issue was detected by using the Coccinelle software.

Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>
---
 net/sctp/proc.c | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/net/sctp/proc.c b/net/sctp/proc.c
index 1cf4b6385418..458087681490 100644
--- a/net/sctp/proc.c
+++ b/net/sctp/proc.c
@@ -475,9 +475,7 @@ static int sctp_remaddr_seq_show(struct seq_file *seq, void *v)
 		 * The current state of this destination. I.e.
 		 * SCTP_ACTIVE, SCTP_INACTIVE, ...
 		 */
-		seq_printf(seq, "%d", tsp->state);
-
-		seq_printf(seq, "\n");
+		seq_printf(seq, "%d\n", tsp->state);
 	}
 
 	sctp_transport_put(transport);
-- 
2.12.2
