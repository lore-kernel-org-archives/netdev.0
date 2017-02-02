From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH v2 iproute2] ss: print tcpi_rcv_mss and tcpi_advmss
Date: Thu, 02 Feb 2017 05:47:27 -0800
Message-ID: <1486043247.13103.30.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1485995810.13103.4.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:35379 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750851AbdBBNr3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 2 Feb 2017 08:47:29 -0500
Received: by mail-pg0-f65.google.com with SMTP id 204so1888831pge.2
        for <netdev@vger.kernel.org>; Thu, 02 Feb 2017 05:47:29 -0800 (PST)
In-Reply-To: <1485995810.13103.4.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

tcpi_rcv_mss and tcpi_advmss tcp info fields were not yet reported
by ss.

While adding GRO support to packetdrill, I found this was useful.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 misc/ss.c |    8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/misc/ss.c b/misc/ss.c
index 4454bd1..7f79eea 100644
--- a/misc/ss.c
+++ b/misc/ss.c
@@ -707,6 +707,8 @@ struct tcpstat {
 	int		    snd_wscale;
 	int		    rcv_wscale;
 	int		    mss;
+	int		    rcv_mss;
+	int		    advmss;
 	unsigned int	    cwnd;
 	unsigned int	    lastsnd;
 	unsigned int	    lastrcv;
@@ -1872,6 +1874,10 @@ static void tcp_stats_print(struct tcpstat *s)
 
 	if (s->mss)
 		printf(" mss:%d", s->mss);
+	if (s->rcv_mss)
+		printf(" rcvmss:%d", s->rcv_mss);
+	if (s->advmss)
+		printf(" advmss:%d", s->advmss);
 	if (s->cwnd)
 		printf(" cwnd:%u", s->cwnd);
 	if (s->ssthresh)
@@ -2189,6 +2195,8 @@ static void tcp_show_info(const struct nlmsghdr *nlh, struct inet_diag_msg *r,
 		s.rttvar	 = (double)info->tcpi_rttvar / 1000;
 		s.ato		 = (double)info->tcpi_ato / 1000;
 		s.mss		 = info->tcpi_snd_mss;
+		s.rcv_mss	 = info->tcpi_rcv_mss;
+		s.advmss	 = info->tcpi_advmss;
 		s.rcv_space	 = info->tcpi_rcv_space;
 		s.rcv_rtt	 = (double)info->tcpi_rcv_rtt / 1000;
 		s.lastsnd	 = info->tcpi_last_data_sent;
