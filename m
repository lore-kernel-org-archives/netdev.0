From: Meelis Roos <mroos@linux.ee>
Subject: [PATCH] silence a warning in ebtables
Date: Wed, 1 Nov 2006 19:01:14 +0200 (EET)
Message-ID: <Pine.SOC.4.61.0611011857340.11421@math.ut.ee>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Return-path: <netdev-owner@vger.kernel.org>
Received: from math.ut.ee ([193.40.36.2]:46312 "EHLO math.ut.ee")
	by vger.kernel.org with ESMTP id S2992675AbWKARBR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Nov 2006 12:01:17 -0500
Received: from math.ut.ee (localhost [IPv6:::1])
	by math.ut.ee (8.12.8+Sun/8.12.8/math-1.2) with ESMTP id kA1H1E28017440
	for <netdev@vger.kernel.org>; Wed, 1 Nov 2006 19:01:14 +0200 (EET)
Received: from localhost (mroos@localhost)
	by math.ut.ee (8.12.8+Sun/8.12.2/Submit) with ESMTP id kA1H1Epw017434
	for <netdev@vger.kernel.org>; Wed, 1 Nov 2006 19:01:14 +0200 (EET)
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

net/bridge/netfilter/ebtables.c: In function 'ebt_dev_check':
net/bridge/netfilter/ebtables.c:89: warning: initialization discards qualifiers from pointer target type

So make the char* a const char * and the warning is gone.

Signed-off-by: Meelis Roos <mroos@linux.ee>

diff --git a/net/bridge/netfilter/ebtables.c b/net/bridge/netfilter/ebtables.c
index 3df55b2..9f85666 100644
--- a/net/bridge/netfilter/ebtables.c
+++ b/net/bridge/netfilter/ebtables.c
@@ -86,7 +86,7 @@ static inline int ebt_do_match (struct e
  static inline int ebt_dev_check(char *entry, const struct net_device *device)
  {
  	int i = 0;
-	char *devname = device->name;
+	const char *devname = device->name;

  	if (*entry == '\0')
  		return 0;

-- 
Meelis Roos (mroos@linux.ee)
