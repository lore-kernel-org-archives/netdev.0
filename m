From: Hangbin Liu <liuhangbin@gmail.com>
Subject: [PATCH iproute2] misc/ss: tcp cwnd should be unsigned
Date: Thu, 22 Sep 2016 16:40:28 +0800
Message-ID: <1474533628-5784-1-git-send-email-liuhangbin@gmail.com>
Cc: Stephen Hemminger <stephen@networkplumber.org>,
        Phil Sutter <phil@nwl.cc>, Hangbin Liu <liuhangbin@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:33909 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751468AbcIVIkt (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 22 Sep 2016 04:40:49 -0400
Received: by mail-pf0-f195.google.com with SMTP id 21so3517119pfy.1
        for <netdev@vger.kernel.org>; Thu, 22 Sep 2016 01:40:49 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

tcp->snd_cwd is a u32, but ss treats it like a signed int. This may
results in negative bandwidth calculations.

Signed-off-by: Hangbin Liu <liuhangbin@gmail.com>
---
 misc/ss.c | 7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/misc/ss.c b/misc/ss.c
index 3b268d9..f67557a 100644
--- a/misc/ss.c
+++ b/misc/ss.c
@@ -754,11 +754,12 @@ struct tcpstat {
 	int		    probes;
 	char		    cong_alg[16];
 	double		    rto, ato, rtt, rttvar;
-	int		    qack, cwnd, ssthresh, backoff;
+	int		    qack, ssthresh, backoff;
 	double		    send_bps;
 	int		    snd_wscale;
 	int		    rcv_wscale;
 	int		    mss;
+	unsigned int	    cwnd;
 	unsigned int	    lastsnd;
 	unsigned int	    lastrcv;
 	unsigned int	    lastack;
@@ -1756,7 +1757,7 @@ static void tcp_stats_print(struct tcpstat *s)
 	if (s->mss)
 		printf(" mss:%d", s->mss);
 	if (s->cwnd)
-		printf(" cwnd:%d", s->cwnd);
+		printf(" cwnd:%u", s->cwnd);
 	if (s->ssthresh)
 		printf(" ssthresh:%d", s->ssthresh);
 
@@ -1856,7 +1857,7 @@ static int tcp_show_line(char *line, const struct filter *f, int family)
 		return 0;
 
 	opt[0] = 0;
-	n = sscanf(data, "%x %x:%x %x:%x %x %d %d %u %d %llx %d %d %d %d %d %[^\n]\n",
+	n = sscanf(data, "%x %x:%x %x:%x %x %d %d %u %d %llx %d %d %d %u %d %[^\n]\n",
 		   &s.ss.state, &s.ss.wq, &s.ss.rq,
 		   &s.timer, &s.timeout, &s.retrans, &s.ss.uid, &s.probes,
 		   &s.ss.ino, &s.ss.refcnt, &s.ss.sk, &rto, &ato, &s.qack, &s.cwnd,
-- 
2.5.5
