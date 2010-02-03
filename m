From: Christoph Egger <siccegge@stud.informatik.uni-erlangen.de>
Subject: [PATCH] obsolete config in kernel source (IP_ROUTE_PERVASIVE)
Date: Wed, 3 Feb 2010 17:05:54 +0100
Message-ID: <20100203160553.GA7461@faui49.informatik.uni-erlangen.de>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="zhXaljGHf11kAtnf"
Cc: siccegge@stud.informatik.uni-erlangen.de,
	vamos@i4.informatik.uni-erlangen.de
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	davem@davemloft.net, kuznet@ms2.inr.ac.ru
Return-path: <netdev-owner@vger.kernel.org>
Received: from faui40.informatik.uni-erlangen.de ([131.188.34.40]:47870 "EHLO
	faui40.informatik.uni-erlangen.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756747Ab0BCQFn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Feb 2010 11:05:43 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--zhXaljGHf11kAtnf
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi all!

	As part of the VAMOS[0] research project at the University of
Erlangen we're checking referential integrity between kernel KConfig
options and in-code Conditional blocks.

	According to my search CONFIG_IP_ROUTE_PERVASIVE is not
defined in any 2.4-2.6 kernel (not #define d and not in
KConfig). However some tiny piece of code still checks it. If this is
really a leftover (as I expect) it might be a good idea to actually
remove that unreachable bit of code.

	Please keep me informed of this patch getting confirmed /
merged so we can keep track of it.

Regards

	Christoph Egger

[0] http://vamos1.informatik.uni-erlangen.de/


--zhXaljGHf11kAtnf
Content-Type: text/x-diff; charset=us-ascii
Content-Disposition: attachment; filename="0001-Get-rid-of-CONFIG_IP_ROUTE_PERVASIVE.patch"

>From 3c33c76fba95a529b67799cefbddbb688807c0fa Mon Sep 17 00:00:00 2001
From: Christoph Egger <siccegge@stud.informatik.uni-erlangen.de>
Date: Wed, 3 Feb 2010 16:37:43 +0100
Subject: [PATCH] Get rid of CONFIG_IP_ROUTE_PERVASIVE

CONFIG_IP_ROUTE_PERVASIVE is missing a corresponding config
IP_ROUTE_PERVASIVE somewhere in KConfig (and missing it for ages
already) so it looks like some aging artefact no longer needed.

Therefor this patch kills of the only remaining reference to that
config Item removing the already unrechable code snipet.

Signed-off-by: Christoph Egger <siccegge@stud.informatik.uni-erlangen.de>
---
 net/ipv4/fib_semantics.c |    4 ----
 1 files changed, 0 insertions(+), 4 deletions(-)

diff --git a/net/ipv4/fib_semantics.c b/net/ipv4/fib_semantics.c
index ed19aa6..235c1ac 100644
--- a/net/ipv4/fib_semantics.c
+++ b/net/ipv4/fib_semantics.c
@@ -527,10 +527,6 @@ static int fib_check_nh(struct fib_config *cfg, struct fib_info *fi,
 	if (nh->nh_gw) {
 		struct fib_result res;
 
-#ifdef CONFIG_IP_ROUTE_PERVASIVE
-		if (nh->nh_flags&RTNH_F_PERVASIVE)
-			return 0;
-#endif
 		if (nh->nh_flags&RTNH_F_ONLINK) {
 			struct net_device *dev;
 
-- 
1.6.3.3


--zhXaljGHf11kAtnf--
