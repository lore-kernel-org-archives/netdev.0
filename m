From: Andreas Henriksson <andreas@fatal.se>
Subject: [PATCH 05/12] Fix typo in tunnel code (o_key vs. i_key).
Date: Fri, 12 Oct 2007 10:56:40 +0200
Message-ID: <1192179407-22461-5-git-send-email-andreas@fatal.se>
References: <1192179407-22461-1-git-send-email-andreas@fatal.se>
 <1192179407-22461-2-git-send-email-andreas@fatal.se>
 <1192179407-22461-3-git-send-email-andreas@fatal.se>
 <1192179407-22461-4-git-send-email-andreas@fatal.se>
Cc: netdev@vger.kernel.org, Herbert Xu <herbert@gondor.apana.org.au>,
	Andreas Henriksson <andreas@fatal.se>
To: shemminger@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 1-1-1-9a.ghn.gbg.bostream.se ([82.182.69.4]:38405 "EHLO
	scream.fatal.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754655AbXJLI5m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Oct 2007 04:57:42 -0400
In-Reply-To: <1192179407-22461-4-git-send-email-andreas@fatal.se>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>

If a dotted quad ikey is specified for GRE tunnels, it gets set as the
okey instead.  This patch fixes it. (http://bugs.debian.org/200714)

Signed-off-by: Andreas Henriksson <andreas@fatal.se>
---
 ip/iptunnel.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/ip/iptunnel.c b/ip/iptunnel.c
index 828d80a..aee526b 100644
--- a/ip/iptunnel.c
+++ b/ip/iptunnel.c
@@ -113,7 +113,7 @@ static int parse_args(int argc, char **argv, int cmd, struct ip_tunnel_parm *p)
 			NEXT_ARG();
 			p->i_flags |= GRE_KEY;
 			if (strchr(*argv, '.'))
-				p->o_key = get_addr32(*argv);
+				p->i_key = get_addr32(*argv);
 			else {
 				if (get_unsigned(&uval, *argv, 0)<0) {
 					fprintf(stderr, "invalid value of \"ikey\"\n");
-- 
1.5.3.4

