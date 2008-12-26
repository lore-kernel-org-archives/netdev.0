From: Dave Jones <davej@redhat.com>
Subject: [PATCH] Allow dependancies of FDDI & Tokenring to be modular.
Date: Fri, 26 Dec 2008 16:52:51 -0500
Message-ID: <20081226215251.GA5136@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:50012 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752848AbYLZVx1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 26 Dec 2008 16:53:27 -0500
Received: from int-mx2.corp.redhat.com (int-mx2.corp.redhat.com [172.16.27.26])
	by mx2.redhat.com (8.13.8/8.13.8) with ESMTP id mBQLrRmu023046
	for <netdev@vger.kernel.org>; Fri, 26 Dec 2008 16:53:27 -0500
Received: from ns3.rdu.redhat.com (ns3.rdu.redhat.com [10.11.255.199])
	by int-mx2.corp.redhat.com (8.13.1/8.13.1) with ESMTP id mBQLrQcW015674
	for <netdev@vger.kernel.org>; Fri, 26 Dec 2008 16:53:27 -0500
Received: from gelk.kernelslacker.org (vpn-12-10.rdu.redhat.com [10.11.12.10])
	by ns3.rdu.redhat.com (8.13.8/8.13.8) with ESMTP id mBQLrQtw021687
	for <netdev@vger.kernel.org>; Fri, 26 Dec 2008 16:53:26 -0500
Received: from gelk.kernelslacker.org (localhost.localdomain [127.0.0.1])
	by gelk.kernelslacker.org (8.14.3/8.14.3) with ESMTP id mBQLqpVm008782
	for <netdev@vger.kernel.org>; Fri, 26 Dec 2008 16:52:51 -0500
Received: (from davej@localhost)
	by gelk.kernelslacker.org (8.14.3/8.14.3/Submit) id mBQLqp90008779
	for netdev@vger.kernel.org; Fri, 26 Dec 2008 16:52:51 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I noticed it isn't possible to build token ring & fddi drivers
without causing LLC, and a bunch of other things to be forced
built-in.  For distro kernels, this means carrying a chunk of
code in the vmlinuz, even if the user doesn't use those protocols.

Signed-off-by: Dave Jones <davej@redhat.com>

-- 
I don't have any hardware for either of these, so I'm unable to test
if it actually works or not, but seeing as the bits in net/ all have
module_init's, it seems they were meant to be allowed to be built this way.

--- linux-2.6.28.noarch/drivers/net/Kconfig~	2008-12-25 23:28:55.000000000 -0500
+++ linux-2.6.28.noarch/drivers/net/Kconfig	2008-12-25 23:29:09.000000000 -0500
@@ -2637,7 +2637,7 @@ config RIONET_RX_SIZE
 	default "128"
 
 config FDDI
-	bool "FDDI driver support"
+	tristate "FDDI driver support"
 	depends on (PCI || EISA || TC)
 	help
 	  Fiber Distributed Data Interface is a high speed local area network
--- linux-2.6.28.noarch/drivers/net/tokenring/Kconfig~	2008-12-25 23:54:29.000000000 -0500
+++ linux-2.6.28.noarch/drivers/net/tokenring/Kconfig	2008-12-25 23:54:34.000000000 -0500
@@ -4,7 +4,7 @@
 
 # So far, we only have PCI, ISA, and MCA token ring devices
 menuconfig TR
-	bool "Token Ring driver support"
+	tristate "Token Ring driver support"
 	depends on NETDEVICES && !UML
 	depends on (PCI || ISA || MCA || CCW)
 	select LLC

-- 
http://www.codemonkey.org.uk
