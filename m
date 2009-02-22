From: James Chapman <jchapman@katalix.com>
Subject: [RFC PATCH 0/8] l2tp: introduce L2TPv3 support
Date: Sun, 22 Feb 2009 17:52:20 GMT
Message-ID: <200902221752.n1MHqK2b006531@bert.katalix.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from katalix.com ([82.103.140.233]:48316 "EHLO mail.katalix.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751813AbZBVRqr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 22 Feb 2009 12:46:47 -0500
Received: from localhost (localhost.localdomain [127.0.0.1])
	by mail.katalix.com (Postfix) with ESMTP id 54629A62087
	for <netdev@vger.kernel.org>; Sun, 22 Feb 2009 17:52:43 +0000 (GMT)
Received: from mail.katalix.com ([127.0.0.1])
	by localhost (mail.katalix.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id 2WRC92DlO5Fy for <netdev@vger.kernel.org>;
	Sun, 22 Feb 2009 17:52:37 +0000 (GMT)
Received: from bert.katalix.com (localhost.localdomain [127.0.0.1])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mail.katalix.com (Postfix) with ESMTPS id BAEC9A620AA
	for <netdev@vger.kernel.org>; Sun, 22 Feb 2009 17:52:21 +0000 (GMT)
Received: (from james@localhost)
	by bert.katalix.com (8.14.2/8.14.2/Submit) id n1MHqK2b006531
	for netdev@vger.kernel.org; Sun, 22 Feb 2009 17:52:20 GMT
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch series implements L2TPv3. It replaces the existing pppol2tp
driver with a number of separate drivers, namely:-

l2tp_core    - L2TP driver core. Always required.
l2tp_ppp     - L2TP PPP
l2tp_eth     - L2TPv3 ethernet pseudowire
l2tp_ip      - L2TPv3 IP encapsulation
l2tp_netlink - L2TPv3 netlink API

The combination of l2tp_core and l2tp_ppp provides
backwards-compatible L2TPv2 pppol2tp functionality.

Except for Patch 6, these patches are not yet ready for the mainline
so don't have my signed-off-by sig. Recently added pppol2tp features
such as namespace support are still to be merged in. I am posting the
patches early to get some feedback before I spend too long
testing. The code is working in basic test setups.

The implementation is as I described in a previous posting to netdev,
archived at http://marc.info/?l=linux-netdev&m=120845482320143&w=4.

The patches are:-

1. Move the existing L2TPv2 pppol2tp driver from drivers/net into a
   new directory, net/l2tp.

2. Split the pppol2tp driver into separate L2TP and PPP parts. This
   is required for L2TPv3 since L2TPv3 can carry protocols other than
   PPP.

3. Add L2TPv3 core protocol support.

4. Update PPP-over-L2TP driver to work over L2TPv3.

5. Add L2TPv3 IP encapsulation (no UDP) support. This creates a new
   L2TPIP socket family. Userspace uses an L2TPIP socket instead of a
   UDP socket when IP encapsulation is required.

6. Small change to genetlink core to export genl_lock/genl_unlock.

7. Add userspace API for L2TPv3 using netlink. Userspace must manage
   L2TPv3 kernel tunnel/session configuration using netlink. The
   previous pppol2tp driver was managed using [gs]etsockopt(), which
   is retained for backwards compatibility. Netlink is used for L2TPv3
   because it is more flexible and the L2TPv3 kernel interface is
   quite complex.

8. Add ethernet pseudowire support. Each ethernet pseudowire has a
   net_device which may be managed by userspace tools.

--
James Chapman
Katalix Systems Ltd
http://www.katalix.com
Catalysts for your Embedded Linux software development 
