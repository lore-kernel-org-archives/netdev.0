From: David Howells <dhowells@redhat.com>
Subject: Can netlink_recvmsg not truncate messages unless asked to?
Date: Fri, 13 Apr 2007 19:04:30 +0100
Message-ID: <1771.1176487470@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:42386 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754112AbXDMSEi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 13 Apr 2007 14:04:38 -0400
Received: from int-mx1.corp.redhat.com (int-mx1.corp.redhat.com [172.16.52.254])
	by mx1.redhat.com (8.13.1/8.13.1) with ESMTP id l3DI4bcO015583
	for <netdev@vger.kernel.org>; Fri, 13 Apr 2007 14:04:37 -0400
Received: from warthog.cambridge.redhat.com (warthog.cambridge.redhat.com [172.16.18.73])
	by int-mx1.corp.redhat.com (8.13.1/8.13.1) with ESMTP id l3DI4aDp030151
	for <netdev@vger.kernel.org>; Fri, 13 Apr 2007 14:04:37 -0400
Received: from redhat.com (localhost.localdomain [127.0.0.1])
	by warthog.cambridge.redhat.com (8.13.8/8.13.8) with ESMTP id l3DI4VaQ001772
	for <netdev@vger.kernel.org>; Fri, 13 Apr 2007 19:04:35 +0100
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Would it be feasible to make netlink_recvmsg() _not_ truncate message unless
it is asked to by having MSG_TRUNC passed to it?

Unless netlink data packets are limited to PAGE_SIZE or less, it's entirely
possible that the kernel can be in a situation where it can't guarantee to get
a buffer large enough to receive a packet larger than that.

What I was trying to do was use recvmsg with MSG_PEEK to grab the nlmsghdr,
and then using that to predict the size of the buffer I need.  But that
doesn't work because a packet might contain multiple netlink messages.

David
