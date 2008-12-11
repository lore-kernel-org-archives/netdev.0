From: Hannes Eder <hannes@hanneseder.net>
Subject: [PATCH 2/9][v2] mISDN: consistently define 'debug' as '*u_int'
Date: Thu, 11 Dec 2008 22:36:00 +0100
Message-ID: <49419a25.02e2660a.1ba9.6cda@mx.google.com>
Cc: Karsten Keil <kkeil@suse.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f13.google.com ([209.85.218.13]:37330 "EHLO
	mail-bw0-f13.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759015AbYLKXAP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Dec 2008 18:00:15 -0500
Received: by bwz6 with SMTP id 6so2825072bwz.13
        for <netdev@vger.kernel.org>; Thu, 11 Dec 2008 15:00:13 -0800 (PST)
Cc: linux-kernel@vger.kernel.org
Cc: kernel-janitors@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Impact: change data type for variable 'debug' from *int to *u_int,
same for the argument type of mISDN_inittimer

In "core.h" mISDN_inittimer is declared with the argument type "*u_int", make
the definition in "timerdev.c" match this.

This fixes also this warnings:

  drivers/isdn/mISDN/layer1.c:391:8: warning: incorrect type in assignment (different signedness)
  drivers/isdn/mISDN/layer1.c:391:8:    expected int *static [toplevel] debug
  drivers/isdn/mISDN/layer1.c:391:8:    got unsigned int [usertype] *deb
  drivers/isdn/mISDN/layer2.c:2200:8: warning: incorrect type in assignment (different signedness)
  drivers/isdn/mISDN/layer2.c:2200:8:    expected int *static [toplevel] debug
  drivers/isdn/mISDN/layer2.c:2200:8:    got unsigned int [usertype] *deb
  drivers/isdn/mISDN/socket.c:769:8: warning: incorrect type in assignment (different signedness)
  drivers/isdn/mISDN/socket.c:769:8:    expected int *static [toplevel] debug
  drivers/isdn/mISDN/socket.c:769:8:    got unsigned int [usertype] *deb

Signed-off-by: Hannes Eder <hannes@hanneseder.net>
Acked-by: Karsten Keil <kkeil@suse.de>
---
 drivers/isdn/mISDN/layer1.c   |    2 +-
 drivers/isdn/mISDN/layer2.c   |    2 +-
 drivers/isdn/mISDN/socket.c   |    2 +-
 drivers/isdn/mISDN/timerdev.c |    4 ++--
 4 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/drivers/isdn/mISDN/layer1.c b/drivers/isdn/mISDN/layer1.c
index fced1a2..4a55d63 100644
--- a/drivers/isdn/mISDN/layer1.c
+++ b/drivers/isdn/mISDN/layer1.c
@@ -21,7 +21,7 @@
 #include "layer1.h"
 #include "fsm.h"
 
-static int *debug;
+static u_int *debug;
 
 struct layer1 {
 	u_long			Flags;
diff --git a/drivers/isdn/mISDN/layer2.c b/drivers/isdn/mISDN/layer2.c
index a7915a1..77fca3b 100644
--- a/drivers/isdn/mISDN/layer2.c
+++ b/drivers/isdn/mISDN/layer2.c
@@ -18,7 +18,7 @@
 #include "fsm.h"
 #include "layer2.h"
 
-static int *debug;
+static u_int *debug;
 
 static
 struct Fsm l2fsm = {NULL, 0, 0, NULL, NULL};
diff --git a/drivers/isdn/mISDN/socket.c b/drivers/isdn/mISDN/socket.c
index e5a20f9..37a2de1 100644
--- a/drivers/isdn/mISDN/socket.c
+++ b/drivers/isdn/mISDN/socket.c
@@ -18,7 +18,7 @@
 #include <linux/mISDNif.h>
 #include "core.h"
 
-static int	*debug;
+static u_int	*debug;
 
 static struct proto mISDN_proto = {
 	.name		= "misdn",
diff --git a/drivers/isdn/mISDN/timerdev.c b/drivers/isdn/mISDN/timerdev.c
index 875fabe..a8d1d9f 100644
--- a/drivers/isdn/mISDN/timerdev.c
+++ b/drivers/isdn/mISDN/timerdev.c
@@ -24,7 +24,7 @@
 #include <linux/module.h>
 #include <linux/mISDNif.h>
 
-static int	*debug;
+static u_int	*debug;
 
 
 struct mISDNtimerdev {
@@ -274,7 +274,7 @@ static struct miscdevice mISDNtimer = {
 };
 
 int
-mISDN_inittimer(int *deb)
+mISDN_inittimer(u_int *deb)
 {
 	int	err;
 
-- 
1.5.6.3

