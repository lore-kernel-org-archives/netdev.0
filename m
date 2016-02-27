From: Deepa Dinamani <deepa.kernel@gmail.com>
Subject: [PATCH v2 2/3] net: ipv4: tcp_probe: Replace timespec with timespec64
Date: Sat, 27 Feb 2016 00:32:16 -0800
Message-ID: <1456561938-7653-3-git-send-email-deepa.kernel@gmail.com>
References: <1456561938-7653-1-git-send-email-deepa.kernel@gmail.com>
Cc: arnd@arndb.de, "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>
To: netdev@vger.kernel.org, y2038@lists.linaro.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:32827 "EHLO
	mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756068AbcB0Ic5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 27 Feb 2016 03:32:57 -0500
Received: by mail-pf0-f193.google.com with SMTP id t66so1652628pfb.0
        for <netdev@vger.kernel.org>; Sat, 27 Feb 2016 00:32:57 -0800 (PST)
In-Reply-To: <1456561938-7653-1-git-send-email-deepa.kernel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

TCP probe log timestamps use struct timespec which is
not y2038 safe. Even though timespec might be good enough here
as it is used to represent delta time, the plan is to get rid
of all uses of timespec in the kernel.
Replace with struct timespec64 which is y2038 safe.

Prints still use unsigned long format and type.

Signed-off-by: Deepa Dinamani <deepa.kernel@gmail.com>
Reviewed-by: Arnd Bergmann <arnd@arndb.de>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Cc: James Morris <jmorris@namei.org>
Cc: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
Cc: Patrick McHardy <kaber@trash.net>
---
 net/ipv4/tcp_probe.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/net/ipv4/tcp_probe.c b/net/ipv4/tcp_probe.c
index ebf5ff5..f6c50af 100644
--- a/net/ipv4/tcp_probe.c
+++ b/net/ipv4/tcp_probe.c
@@ -187,13 +187,13 @@ static int tcpprobe_sprint(char *tbuf, int n)
 {
 	const struct tcp_log *p
 		= tcp_probe.log + tcp_probe.tail;
-	struct timespec tv
-		= ktime_to_timespec(ktime_sub(p->tstamp, tcp_probe.start));
+	struct timespec64 ts
+		= ktime_to_timespec64(ktime_sub(p->tstamp, tcp_probe.start));
 
 	return scnprintf(tbuf, n,
 			"%lu.%09lu %pISpc %pISpc %d %#x %#x %u %u %u %u %u\n",
-			(unsigned long)tv.tv_sec,
-			(unsigned long)tv.tv_nsec,
+			(unsigned long)ts.tv_sec,
+			(unsigned long)ts.tv_nsec,
 			&p->src, &p->dst, p->length, p->snd_nxt, p->snd_una,
 			p->snd_cwnd, p->ssthresh, p->snd_wnd, p->srtt, p->rcv_wnd);
 }
-- 
1.9.1
