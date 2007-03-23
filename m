From: James Chapman <jchapman@katalix.com>
Subject: [PATCH 0/5 2.6.21-rc4] l2tp: introduce PPP over L2TP driver
Date: Fri, 23 Mar 2007 23:07:27 GMT
Message-ID: <200703232307.l2NN7RRx010804@quickie.katalix.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from s36.avahost.net ([74.53.95.194]:33021 "EHLO s36.avahost.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S2992611AbXCWXIL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Mar 2007 19:08:11 -0400
Received: from jchapman.plus.com ([84.92.108.75] helo=quickie.katalix.com)
	by s36.avahost.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.63)
	(envelope-from <jchapman@katalix.com>)
	id 1HUsrY-00055X-K4
	for netdev@vger.kernel.org; Fri, 23 Mar 2007 18:08:01 -0500
Received: from quickie.katalix.com (quickie.katalix.com [127.0.0.1])
	by quickie.katalix.com (8.13.5/8.13.5) with ESMTP id l2NN7Re4010826
	for <netdev@vger.kernel.org>; Fri, 23 Mar 2007 23:07:28 GMT
Received: (from james@localhost)
	by quickie.katalix.com (8.13.5/8.13.5/Submit) id l2NN7RRx010804
	for netdev@vger.kernel.org; Fri, 23 Mar 2007 23:07:27 GMT
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch set adds a driver for PPP over L2TP. Patches to follow.

The implementation uses the existing PPPoX subsystem that is currently
used only by PPPoE. A userspace daemon handles all L2TP control
protocol messages, while a PPPoX socket carries user data. The system
architecture is similar to PPPoE, where a pppd plugin uses the PPPoX
socket to send/receive PPP frames over an L2TP tunnel. PPP control
frames are delivered to pppd while data frames are handled entirely by
the kernel.

There are 5 patches in the series:-

1 - pppol2tp driver core. New code.

2 - API changes for L2TP. Adds definitions for L2TP in existing headers.

3 - Change to PPPoX core to allow PPPoX protocol modules such as
    pppol2tp to be autoloaded via modprobe.conf.

4 - Kernel makefile and config file changes.

5 - Adds an entry to MAINTAINERS file.

The driver is being used on x86, ia64, ppc, arm, mips32 and possibly
other architectures. It is also known to work on multi-core SMP boxes.

Sparse emits some warnings to do with pointer namespaces in the
msg_iov code. The same warnings are output by net/socket.c from which
some of this code is derived.

Although this driver is being actively used in various L2TP setups,
I'm sure it would benefit from review here.

--
James Chapman
Katalix Systems Ltd
http://www.katalix.com
Catalysts for your Embedded Linux software development
