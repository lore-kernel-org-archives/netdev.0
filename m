From: Matthias Tafelmeier <matthias.tafelmeier@gmx.net>
Subject: [PATCH v7 07/10] ss: symmetrical subhandler output extension example
Date: Thu, 10 Sep 2015 21:35:05 +0200
Message-ID: <1441913708-15532-8-git-send-email-matthias.tafelmeier@gmx.net>
References: <1441913708-15532-1-git-send-email-matthias.tafelmeier@gmx.net>
Cc: hagen@jauu.net, shemminger@osdl.org, fw@strlen.de,
	edumazet@google.com, daniel@iogearbox.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.net ([212.227.17.21]:54888 "EHLO mout.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752626AbbIJTfn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Sep 2015 15:35:43 -0400
In-Reply-To: <1441913708-15532-1-git-send-email-matthias.tafelmeier@gmx.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This small sized patch shall convey the locations which have to be
changed for a symmetrical output extension. Symmetrical means in this
context all existing semantically related handlers in the diverse
formatters (for hr and json up to now).

Suggested-by: Hagen Paul Pfeifer <hagen@jauu.net>
Signed-off-by: Matthias Tafelmeier <matthias.tafelmeier@gmx.net>
---
 misc/ss_hr_fmt.c   | 2 ++
 misc/ss_json_fmt.c | 2 ++
 2 files changed, 4 insertions(+)

diff --git a/misc/ss_hr_fmt.c b/misc/ss_hr_fmt.c
index 2f09838..4046ebf 100644
--- a/misc/ss_hr_fmt.c
+++ b/misc/ss_hr_fmt.c
@@ -82,6 +82,8 @@ static void tcp_stats_hr_fmt(struct tcpstat *s)
 		printf(" reordering:%d", s->reordering);
 	if (s->rcv_rtt)
 		printf(" rcv_rtt:%g", s->rcv_rtt);
+	if (s->rcv_space)
+		printf(" rcv_space:%d", s->rcv_space);
 
 	CHECK_FMT_ADAPT(s->rcv_space, s,
 	hr_handler_must_be_adapted_accordingly_when_json_fmt_is_extended);
diff --git a/misc/ss_json_fmt.c b/misc/ss_json_fmt.c
index a927952..1dff57a 100644
--- a/misc/ss_json_fmt.c
+++ b/misc/ss_json_fmt.c
@@ -160,6 +160,8 @@ static void tcp_stats_json_fmt(struct tcpstat *s)
 		jsonw_int_field(json_wr, "reordering", s->reordering);
 	if (s->rcv_rtt)
 		jsonw_float_field(json_wr, "rcv_rtt", s->rcv_rtt);
+	if (s->rcv_space)
+		jsonw_int_field(json_wr, "rcv_space", s->rcv_space);
 
 	/*deal with special case */
 	res_json_fmt_branch(s->ss.state == SS_LISTEN, ' ');
-- 
1.9.1
