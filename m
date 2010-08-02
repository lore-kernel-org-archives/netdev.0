From: Andreas Henriksson <andreas@fatal.se>
Subject: [PATCH] tc: make symbols loaded from tc action modules global.
Date: Mon, 2 Aug 2010 09:30:33 +0200
Message-ID: <20100802073032.GA32046@amd64.fatal.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay-h32.telenor.se ([213.150.131.5]:54902 "EHLO
	smtprelay-h32.telenor.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751549Ab0HBHsN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Aug 2010 03:48:13 -0400
Received: from ipb1.telenor.se (ipb1.telenor.se [195.54.127.164])
	by smtprelay-h32.telenor.se (Postfix) with ESMTP id 5F610E8AF1
	for <netdev@vger.kernel.org>; Mon,  2 Aug 2010 09:22:34 +0200 (CEST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fixes problems with xtables based MARK target ("ipt" module).
When tc loads the "ipt" (xt) module it kept the symbols local,
this made loading of libxtables not find the required struct.

currently ipt/xt is the only tc action module.
iproute2 never seem to do dlclose.
hopefully the modules doesn't export more symbols then needed.

In this situation hopefully the RTLD_GLOBAL flag won't hurt us.

I've been using this patch in the Debian package of iproute for
the last 3 weeks and noone has complained.
( This fixes http://bugs.debian.org/584898 )

Signed-off-by: Andreas Henriksson <andreas@fatal.se>
---
 tc/m_action.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/tc/m_action.c b/tc/m_action.c
index a198158..6464b2e 100644
--- a/tc/m_action.c
+++ b/tc/m_action.c
@@ -99,7 +99,7 @@ restart_s:
 	}
 
 	snprintf(buf, sizeof(buf), "%s/m_%s.so", get_tc_lib(), str);
-	dlh = dlopen(buf, RTLD_LAZY);
+	dlh = dlopen(buf, RTLD_LAZY | RTLD_GLOBAL);
 	if (dlh == NULL) {
 		dlh = aBODY;
 		if (dlh == NULL) {
-- 
1.7.1

