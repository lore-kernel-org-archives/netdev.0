From: James Chapman <jchapman@katalix.com>
Subject: [PATCH 0/5 2.6.22-rc6] L2TP: Introduce PPP-over-L2TP driver
Date: Wed, 27 Jun 2007 23:19:38 +0100
Message-ID: <200706272219.l5RMJcLU004929@quickie.katalix.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from s36.avahost.net ([74.53.95.194]:60753 "EHLO s36.avahost.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758017AbXF0WUU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Jun 2007 18:20:20 -0400
Received: from jchapman.plus.com ([84.92.108.75] helo=quickie.katalix.com)
	by s36.avahost.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.63)
	(envelope-from <jchapman@katalix.com>)
	id 1I3fj5-00047X-2d
	for netdev@vger.kernel.org; Wed, 27 Jun 2007 17:11:03 -0500
Received: from quickie.katalix.com (quickie.katalix.com [127.0.0.1])
	by quickie.katalix.com (8.13.5/8.13.5) with ESMTP id l5RMJcru004931
	for <netdev@vger.kernel.org>; Wed, 27 Jun 2007 23:19:38 +0100
Received: (from james@localhost)
	by quickie.katalix.com (8.13.5/8.13.5/Submit) id l5RMJcLU004929
	for netdev@vger.kernel.org; Wed, 27 Jun 2007 23:19:38 +0100
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch set adds a driver for PPP over L2TP. Patches to follow.

The following changes have been made since the previous version
submitted 26-MAY-07.

- Add new encap_rcv field to struct udp_sock in udp.h for use by
  encapsulated sockets. This is set to a protocol specific receive
  handler for encap sockets. This is instead of the global funcptr
  that was in the previous version.

- Rebased to 2.6.22-rc6.

- Update SOL_PPPOL2TP value to avoid clash with RxRPC.

- Move pppol2tp.h into the api-changes patch so that the patch can be
  applied in isolation.

- Update core driver to use skb_transport_header() and
  skb_network_header() functions rather than the old skb->h and
  skb->nh fields.


About this patch series:

The implementation uses the existing PPPoX subsystem that is currently
used only by PPPoE. A userspace daemon handles all L2TP control
protocol messages, while a PPPoX socket carries user data. The system
architecture is similar to PPPoE, where a pppd plugin uses the PPPoX
socket to send/receive PPP frames over an L2TP tunnel. PPP control
frames are delivered to pppd while data frames are handled entirely by
the kernel.

There are 5 patches in the series:-

1 - Introduce new UDP encapsulation type for L2TP.

2 - API changes for L2TP. Adds definitions for L2TP in existing headers.

3 - pppol2tp driver core. New code. Requires patches 1, 2, and the 
    recently applied skb_queue_walk_safe patch.

4 - Add an entry to MAINTAINERS file for this driver.

5 - Add in-kernel documentation.

The driver is being used on x86, ia64, ppc, arm, mips32 and possibly
other architectures. It is also known to work on multi-core SMP boxes.

--
James Chapman
Katalix Systems Ltd
http://www.katalix.com
Catalysts for your Embedded Linux software development
