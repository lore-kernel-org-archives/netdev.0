From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH iproute2-3.8 3/6] iproute2: Improve "ip netns add" failure error message
Date: Thu, 17 Jan 2013 16:46:43 -0800
Message-ID: <87obgn48ss.fsf_-_@xmission.com>
References: <87a9u4q7k9.fsf@xmission.com>
	<1354039239.2701.8.camel@bwh-desktop.uk.solarflarecom.com>
	<87622v5ngt.fsf_-_@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, "Serge E. Hallyn" <serge@hallyn.com>,
	Ben Hutchings <bhutchings@solarflare.com>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:54126 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753825Ab3ARAq4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Jan 2013 19:46:56 -0500
In-Reply-To: <87622v5ngt.fsf_-_@xmission.com> (Eric W. Biederman's message of
	"Thu, 17 Jan 2013 16:44:34 -0800")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Report the name of the network namespace that could not be
added.

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 ip/ipnetns.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/ip/ipnetns.c b/ip/ipnetns.c
index ae55090..4fce379 100644
--- a/ip/ipnetns.c
+++ b/ip/ipnetns.c
@@ -135,8 +135,8 @@ static int netns_exec(int argc, char **argv)
 	snprintf(net_path, sizeof(net_path), "%s/%s", NETNS_RUN_DIR, name);
 	netns = open(net_path, O_RDONLY);
 	if (netns < 0) {
-		fprintf(stderr, "Cannot open network namespace: %s\n",
-			strerror(errno));
+		fprintf(stderr, "Cannot open network namespace %s: %s\n",
+			name, strerror(errno));
 		return EXIT_FAILURE;
 	}
 	if (setns(netns, CLONE_NEWNET) < 0) {
-- 
1.7.5.4
