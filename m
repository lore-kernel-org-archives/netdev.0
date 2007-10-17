From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: multicast: bug or "feature"
Date: Wed, 17 Oct 2007 15:58:05 -0400
Message-ID: <4716694D.6030508@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Brian Haley <brian.haley@hp.com>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel9.hp.com ([156.153.255.214]:53545 "EHLO atlrel9.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1763284AbXJQT60 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Oct 2007 15:58:26 -0400
Received: from smtp2.fc.hp.com (smtp2.fc.hp.com [15.11.136.114])
	by atlrel9.hp.com (Postfix) with ESMTP id 62A8035A04
	for <netdev@vger.kernel.org>; Wed, 17 Oct 2007 15:58:06 -0400 (EDT)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

We've been trying to field some questions regarding multicast
behavior and one such behavior has stumped us.

I've reproduced the following behavior on 2.6.23.

The application opens 2 sockets.  One socket is the receiver
and it simply binds to 0.0.0.0:2000 and joins a multicast group
on interface eth0 (for the test we used 224.0.1.3).  The other
socket is the sender.  It turns off MULTICAST_LOOP, sets MULTICAST_IF
to eth1, and sends a packet to the group that the first socket
joined.

We are expecting to receive the data on the receiver socket, but
nothing comes back.

Running tcpdump on both interfaces during the test, I see the packet
on both interfaces, ie. I see it sent on eth0 and received on eth1 with
IP statistics going up appropriately.

Looking at the group memberships, I see the receiving interface as
part of the group and IGMP messages were on the wire.

So, before I try to spend time figuring out where the packet went is
why, I'd like to know if this is a Linux "feature".

Thanks
-vlad
