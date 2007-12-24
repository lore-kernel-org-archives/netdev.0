From: "Denys Fedoryshchenko" <denys@visp.net.lb>
Subject: iproute2 action ipt + iptables 1.4.0
Date: Mon, 24 Dec 2007 17:11:47 +0200
Message-ID: <20071224151147.M93927@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain;
	charset=koi8-r
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from usermail.globalproof.net ([194.146.153.18]:48831 "EHLO
	usermail.globalproof.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750942AbXLXPRR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Dec 2007 10:17:17 -0500
Received: from visp.net.lb (localhost [127.0.0.1])
	by usermail.globalproof.net (Postfix) with ESMTP id 8AA0ABDBB7
	for <netdev@vger.kernel.org>; Mon, 24 Dec 2007 17:11:47 +0200 (EET)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi again :-)

Happy holidays :-)

It seems there is serious break in compatibility, but can be fixed by ugly
way. Maybe just to add patch below, and to search libipt AND libxt (for my
case i just edit and change libipt to libxt, but it can be handled in more
smart way.
After i apply all this - it seems working fine.

iff -Naur iproute2-git/tc/m_ipt.c iproute2-new/tc/m_ipt.c
--- iproute2-git/tc/m_ipt.c     2007-12-24 16:59:19.000000000 +0200
+++ iproute2-new/tc/m_ipt.c     2007-12-24 17:07:11.000000000 +0200
@@ -69,6 +69,27 @@
 }

 void
+xtables_register_target(struct iptables_target *me)
+{
+/*      fprintf(stderr, "\nDummy register_target %s \n", me->name);
+*/
+       me->next = t_list;
+       t_list = me;
+
+}
+
+
+void
+xtables_register_match(struct iptables_target *me)
+{
+/*      fprintf(stderr, "\nDummy register_target %s \n", me->name);
+*/
+       me->next = t_list;
+       t_list = me;
+
+}
+
+void
 exit_tryhelp(int status)
 {
        fprintf(stderr, "Try `%s -h' or '%s --help' for more information.\n",

There is trivial patch also, for bug (IMHO bug) in searching lowercased
library. If patch not applied - second time it will try to open lib_dir by
dlopen:-)

--- iproute2-git/tc/m_ipt.c     2007-12-24 16:59:19.000000000 +0200
+++ iproute2/tc/m_ipt.c 2007-12-24 17:00:41.000000000 +0200
@@ -251,7 +251,7 @@
        sprintf(path,  "%s/libipt_%s.so",lib_dir, new_name);
        handle = dlopen(path, RTLD_LAZY);
        if (!handle) {
-               sprintf(path, lib_dir, "/libipt_%s.so", lname);
+               sprintf(path, "%s/libipt_%s.so", lib_dir , lname);
                handle = dlopen(path, RTLD_LAZY);
                if (!handle) {
                        fputs(dlerror(), stderr);

Sorry for probably bad style/code, i am not programmer at all.


--
Denys Fedoryshchenko
Technical Manager
Virtual ISP S.A.L.

