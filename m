From: Anton Danilov <littlesmilingcloud@gmail.com>
Subject: [patch] bridge-utils: show selected bridge
Date: Wed, 12 Jan 2011 18:29:16 +0300
Message-ID: <AANLkTi=2TGTSnFLAV0ucST7oWeaxHfchhxPd3y=F-dai@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:54199 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754699Ab1ALP3R (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Jan 2011 10:29:17 -0500
Received: by vws16 with SMTP id 16so173903vws.19
        for <netdev@vger.kernel.org>; Wed, 12 Jan 2011 07:29:16 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

diff --git a/brctl/brctl_cmd.c b/brctl/brctl_cmd.c
index d37e99c..d95fe54 100644
--- a/brctl/brctl_cmd.c
+++ b/brctl/brctl_cmd.c
@@ -338,8 +338,14 @@ static int show_bridge(const char *name, void *arg)

 static int br_cmd_show(int argc, char *const* argv)
 {
+       int i = 0;
+
        printf("bridge name\tbridge id\t\tSTP enabled\tinterfaces\n");
-       br_foreach_bridge(show_bridge, NULL);
+       if (argc == 1)
+               br_foreach_bridge(show_bridge, NULL);
+       else
+               for(i = 2; i <= argc; i++)
+                       show_bridge(argv[i - 1], NULL);
        return 0;
 }

@@ -454,7 +460,8 @@ static const struct command commands[] = {
          "<bridge> <port> <cost>\tset path cost" },
        { 3, "setportprio", br_cmd_setportprio,
          "<bridge> <port> <prio>\tset port priority" },
-       { 0, "show", br_cmd_show, "\t\t\tshow a list of bridges" },
+       { 0, "show", br_cmd_show,
+         "[ <bridge> ]\t\tshow a list of bridges" },
        { 1, "showmacs", br_cmd_showmacs,
          "<bridge>\t\tshow a list of mac addrs"},
        { 1, "showstp", br_cmd_showstp,
-- 
Anton.
