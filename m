From: Martin KaFai Lau <kafai@fb.com>
Subject: [PATCH iproute2 -master] ss: Add tcp_info fields data_segs_in/out
Date: Fri, 17 Jun 2016 17:38:53 -0700
Message-ID: <1466210333-144942-1-git-send-email-kafai@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev <netdev@vger.kernel.org>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:42337 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752843AbcFRAi6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Jun 2016 20:38:58 -0400
Received: from pps.filterd (m0001303.ppops.net [127.0.0.1])
	by m0001303.ppops.net (8.16.0.11/8.16.0.11) with SMTP id u5I0cR7r020655
	for <netdev@vger.kernel.org>; Fri, 17 Jun 2016 17:38:57 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by m0001303.ppops.net with ESMTP id 23kt3hrte0-4
	(version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Fri, 17 Jun 2016 17:38:57 -0700
Received: from facebook.com (2401:db00:11:d0a6:face:0:33:0)	by
 mx-out.facebook.com (10.223.100.97) with ESMTP	id
 0900064634ed11e6bf8824be0593f280-41b4d6b0 for <netdev@vger.kernel.org>;	Fri,
 17 Jun 2016 17:38:54 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

tcp_info fields, data_segs_in and data_segs_out, have been added to the
kernel in commit a44d6eacdaf5 ("tcp: Add RFC4898 tcpEStatsPerfDataSegsOut/In")
since kernel 4.6.

This patch supports those fileds in ss:

ESTAB      801736 360                            face:face:face:face::1:22                                      face:face:face:face::face:46779
         cubic wscale:9,7 rto:223 rtt:22.195/8.202 ato:40 mss:1428 cwnd:11 ssthresh:7 bytes_acked:203649 bytes_received:334034603 segs_out:18513 segs_in:241825 data_segs_out:4192 data_segs_in:241672 send 5.7Mbps lastsnd:2 lastack:3 pacing_rate 6.8Mbps unacked:10 retrans:0/1 rcv_rtt:29.375 rcv_space:1241704 minrtt:0.013

Signed-off-by: Martin KaFai Lau <kafai@fb.com>
---
 misc/ss.c | 8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/misc/ss.c b/misc/ss.c
index 9c456d4..02be7e7 100644
--- a/misc/ss.c
+++ b/misc/ss.c
@@ -766,6 +766,8 @@ struct tcpstat {
 	unsigned long long  bytes_received;
 	unsigned int	    segs_out;
 	unsigned int	    segs_in;
+	unsigned int	    data_segs_out;
+	unsigned int	    data_segs_in;
 	unsigned int	    unacked;
 	unsigned int	    retrans;
 	unsigned int	    retrans_total;
@@ -1716,6 +1718,10 @@ static void tcp_stats_print(struct tcpstat *s)
 		printf(" segs_out:%u", s->segs_out);
 	if (s->segs_in)
 		printf(" segs_in:%u", s->segs_in);
+	if (s->data_segs_out)
+		printf(" data_segs_out:%u", s->data_segs_out);
+	if (s->data_segs_in)
+		printf(" data_segs_in:%u", s->data_segs_in);
 
 	if (s->dctcp && s->dctcp->enabled) {
 		struct dctcpstat *dctcp = s->dctcp;
@@ -2022,6 +2028,8 @@ static void tcp_show_info(const struct nlmsghdr *nlh, struct inet_diag_msg *r,
 		s.bytes_received = info->tcpi_bytes_received;
 		s.segs_out = info->tcpi_segs_out;
 		s.segs_in = info->tcpi_segs_in;
+		s.data_segs_out = info->tcpi_data_segs_out;
+		s.data_segs_in = info->tcpi_data_segs_in;
 		s.not_sent = info->tcpi_notsent_bytes;
 		if (info->tcpi_min_rtt && info->tcpi_min_rtt != ~0U)
 			s.min_rtt = (double) info->tcpi_min_rtt / 1000;
-- 
2.5.1
