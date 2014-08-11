From: Marcel Holtmann <marcel@holtmann.org>
Subject: netlink_deliver_tap is broken
Date: Mon, 11 Aug 2014 14:38:48 -0700
Message-ID: <36718D51-62DE-40B4-AE97-F82F3704597C@holtmann.org>
Mime-Version: 1.0 (Mac OS X Mail 7.3 \(1878.6\))
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: Network Development <netdev@vger.kernel.org>
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:39015 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753692AbaHKViP convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Aug 2014 17:38:15 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Daniel,

the netlink tap functionality is not really usable. At least not from a nlmon perspective. It has three fundamental problems.

a) Multicast netlink messages are not delivered to a registered tap when you do not have any member subscribed to the multicast group

b) Multicast netlink messages are delivered multiple times when you have multiple clients subscribed to that multicast group.

c) Unicast netlink messages are filtered out by the client socket filter meaning they never get to the tap

I think all 3 need to be actually fixed to have nlmon being useful for netlink tracing. I did a simple approach by moving netlink_deliver_tap into the actual right places before the filters. However that does not seems to work since it causes sleeping in wrong context.

You might want to have a look at it to make nlmon actually functional complete and not depending on some external multicast membership or socket filters.

Regards

Marcel
