From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] sysctl: fix min/max handling in
 __do_proc_doulongvec_minmax()
Date: Sat, 02 Oct 2010 15:17:49 +0200
Message-ID: <1286025469.2582.1806.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel <linux-kernel@vger.kernel.org>,
	Robin Holt <holt@sgi.com>, Willy Tarreau <w@1wt.eu>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	"Pekka Savola (ipv6)" <pekkas@netcore.fi>, netdev@vger.kernel.org,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	"Pekka Savola (ipv6)" <pekkas@netcore.fi>,
	Patrick McHardy <kaber@trash.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:53719 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754378Ab0JBNR5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 2 Oct 2010 09:17:57 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When proc_doulongvec_minmax() is used with an array of longs,
and no min/max check requested (.extra1 or .extra2 being NULL), we
dereference a NULL pointer for the second element of the array.

Noticed while doing some changes in network stack for the "16TB problem"

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 kernel/sysctl.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/kernel/sysctl.c b/kernel/sysctl.c
index f88552c..4fba86d 100644
--- a/kernel/sysctl.c
+++ b/kernel/sysctl.c
@@ -2500,7 +2500,8 @@ static int __do_proc_doulongvec_minmax(void *data, struct ctl_table *table, int
 				break;
 			if (neg)
 				continue;
-			if ((min && val < *min) || (max && val > *max))
+			if ((table->extra1 && val < *min) ||
+			    (table->extra2 && val > *max))
 				continue;
 			*i = val;
 		} else {


