From: David Howells <dhowells@redhat.com>
Subject: Possible bug in netlink_recvmsg()
Date: Fri, 13 Apr 2007 19:08:31 +0100
Message-ID: <1864.1176487711@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:43881 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754122AbXDMSIh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 13 Apr 2007 14:08:37 -0400
Received: from int-mx1.corp.redhat.com (int-mx1.corp.redhat.com [172.16.52.254])
	by mx1.redhat.com (8.13.1/8.13.1) with ESMTP id l3DI8aFN018607
	for <netdev@vger.kernel.org>; Fri, 13 Apr 2007 14:08:36 -0400
Received: from warthog.cambridge.redhat.com (warthog.cambridge.redhat.com [172.16.18.73])
	by int-mx1.corp.redhat.com (8.13.1/8.13.1) with ESMTP id l3DI8ZxW031582
	for <netdev@vger.kernel.org>; Fri, 13 Apr 2007 14:08:35 -0400
Received: from redhat.com (localhost.localdomain [127.0.0.1])
	by warthog.cambridge.redhat.com (8.13.8/8.13.8) with ESMTP id l3DI8Vn4001865
	for <netdev@vger.kernel.org>; Fri, 13 Apr 2007 19:08:31 +0100
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


As I understand it, according to the recvmsg() manual page, if the packet
being returned is larger than the buffer provided, and the protocol does not
support piecemeal reception of data, then:

 (1) the buffer should be filled,

 (2) MSG_TRUNC should be set in msg_flags, and

 (3) the length of the full packet, including the discarded bit should be
     returned.

AF_NETLINK sockets, however, do not do (3).  See this bit in netlink_recvmsg():

	copied = skb->len;
	if (len < copied) {
		msg->msg_flags |= MSG_TRUNC;
		copied = len;
	}

Or is this only true if the caller of recvmsg() passes MSG_TRUNC in?

David
