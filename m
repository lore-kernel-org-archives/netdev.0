From: Thomas Jarosch <thomas.jarosch@intra2net.com>
Subject: [iproute2 PATCH 2/2] tc: Use correct variable type for get_distribution()
 result
Date: Wed, 23 Nov 2011 22:15:19 +0100
Message-ID: <4ECD6267.3090406@intra2net.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from re04.intra2net.com ([82.165.46.26]:43796 "EHLO
	re04.intra2net.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753472Ab1KWVPW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Nov 2011 16:15:22 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

get_distribution() returns an int.

cppcheck reported:
[tc/q_netem.c:243]: (style) Checking if unsigned variable 'dist_size' is less than zero.

The mismatch actually rendered the error checking
after get_distribution() ineffective.

Signed-off-by: Thomas Jarosch <thomas.jarosch@intra2net.com>
---
 tc/q_netem.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/tc/q_netem.c b/tc/q_netem.c
index 01639a8..6dc40bd 100644
--- a/tc/q_netem.c
+++ b/tc/q_netem.c
@@ -125,7 +125,7 @@ static int get_ticks(__u32 *ticks, const char *str)
 static int netem_parse_opt(struct qdisc_util *qu, int argc, char **argv,
 			   struct nlmsghdr *n)
 {
-	size_t dist_size = 0;
+	int dist_size = 0;
 	struct rtattr *tail;
 	struct tc_netem_qopt opt;
 	struct tc_netem_corr cor;
-- 
1.7.6.4
