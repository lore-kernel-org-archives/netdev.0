From: Thomas Habets <thomas@habets.pp.se>
Subject: [PATCH] iputils ping,ping6: use sig_atomic_t for flags set by signal
 handlers
Date: Sun, 5 Sep 2010 14:52:48 +0200 (CEST)
Message-ID: <alpine.DEB.1.10.1009051432540.13886@red.crap.retrofitta.se>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; format=flowed; charset=US-ASCII
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from reptilian.habets.pp.se ([193.151.93.131]:1439 "EHLO
	reptilian.habets.pp.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753251Ab0IEMw6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 5 Sep 2010 08:52:58 -0400
Received: from red.crap.retrofitta.se (10.200.216.81.static.apv.siw.siwnet.net [81.216.200.10])
	by reptilian.habets.pp.se (Postfix) with ESMTP id 469353C898
	for <netdev@vger.kernel.org>; Sun,  5 Sep 2010 14:52:49 +0200 (CEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Required by ISO C99 7.14.1.1 paragraph 5.

diff --git a/ping_common.c b/ping_common.c
index 82320b1..e0edf39 100644
--- a/ping_common.c
+++ b/ping_common.c
@@ -27,8 +27,8 @@ int preload;
  int deadline = 0;              /* time to die */
  int lingertime = MAXWAIT*1000;
  struct timeval start_time, cur_time;
-volatile int exiting;
-volatile int status_snapshot;
+volatile sig_atomic_t exiting;
+volatile sig_atomic_t status_snapshot;
  int confirm = 0;

  /* Stupid workarounds for bugs/missing functionality in older linuces.
