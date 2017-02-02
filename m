From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH iproute2] ss: print tcpi_rcv_mss
Date: Wed, 01 Feb 2017 16:36:50 -0800
Message-ID: <1485995810.13103.4.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:34661 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751088AbdBBAgx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 1 Feb 2017 19:36:53 -0500
Received: by mail-pf0-f194.google.com with SMTP id y143so73652pfb.1
        for <netdev@vger.kernel.org>; Wed, 01 Feb 2017 16:36:53 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

tcpi_rcv_mss tcp info field was not yet reported by ss.

While adding GRO support to packetdrill, I found this was useful.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 misc/ss.c |    4 ++++
 1 file changed, 4 insertions(+)

diff --git a/misc/ss.c b/misc/ss.c
index 4454bd1..6e4f84a 100644
--- a/misc/ss.c
+++ b/misc/ss.c
@@ -707,6 +707,7 @@ struct tcpstat {
 	int		    snd_wscale;
 	int		    rcv_wscale;
 	int		    mss;
+	int		    rcv_mss;
 	unsigned int	    cwnd;
 	unsigned int	    lastsnd;
 	unsigned int	    lastrcv;
@@ -1872,6 +1873,8 @@ static void tcp_stats_print(struct tcpstat *s)
 
 	if (s->mss)
 		printf(" mss:%d", s->mss);
+	if (s->rcv_mss)
+		printf(" rcvmss:%d", s->rcv_mss);
 	if (s->cwnd)
 		printf(" cwnd:%u", s->cwnd);
 	if (s->ssthresh)
@@ -2189,6 +2192,7 @@ static void tcp_show_info(const struct nlmsghdr *nlh, struct inet_diag_msg *r,
 		s.rttvar	 = (double)info->tcpi_rttvar / 1000;
 		s.ato		 = (double)info->tcpi_ato / 1000;
 		s.mss		 = info->tcpi_snd_mss;
+		s.rcv_mss	 = info->tcpi_rcv_mss;
 		s.rcv_space	 = info->tcpi_rcv_space;
 		s.rcv_rtt	 = (double)info->tcpi_rcv_rtt / 1000;
 		s.lastsnd	 = info->tcpi_last_data_sent;
