From: emil@linux.org.pl
Subject: Loopback and net namespace
Date: Fri, 24 Apr 2009 23:55:36 +0200 (CEST)
Message-ID: <alpine.LNX.2.00.0904242322490.1162@duch.mimuw.edu.pl>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; format=flowed; charset=US-ASCII
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from duch.mimuw.edu.pl ([193.0.96.2]:41392 "EHLO duch.mimuw.edu.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751188AbZDXWE3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 24 Apr 2009 18:04:29 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Currently it is impossible to use both net namespace and sysfs
because sysfs does not allow two devices with the same name
and each net namespace has to have loopback device.

To have this working there must be possibility to
create loopback devices with different names.

The easiest way to acomplish this seems to be with this patch below.

I know the devices will be seen in each namespace, but sometimes
the only thing that is needed is network environment separation.
For example when I need to run two different services on the same TCP port
bound to 0.0.0.0.

This patch will not break anything and allow people to test
net namespace functionality.


Emil Stepniewski



----------------------- CUT HERE ------------------------------

--- /usr/src/linux/drivers/net/loopback.c  2008-04-17 04:49:44.000000000 +0200
+++ /usr/src/linux/drivers/net/loopback.c.new      2009-04-24 23:27:43.000000000 +0200
@@ -254,7 +254,11 @@
         int err;

         err = -ENOMEM;
+#ifdef CONFIG_SYSFS
+       dev = alloc_netdev(0,  (net == &init_net) ? "lo" : "lo%d", loopback_setup);
+#else
         dev = alloc_netdev(0, "lo", loopback_setup);
+#endif
         if (!dev)
                 goto out;

