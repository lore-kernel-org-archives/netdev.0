From: Nikolay Aleksandrov <nikolay@redhat.com>
Subject: [PATCH -net v2 0/2] net: netpoll and netconsole fixes
Date: Thu, 19 Sep 2013 15:02:34 +0200
Message-ID: <1379595756-3527-1-git-send-email-nikolay@redhat.com>
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:53249 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752033Ab3ISNGJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Sep 2013 09:06:09 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,
This small patchset fixes a possible race condition in netpoll_cleanup
which can lead to a NULL pointer dereference because the check and
manipulation of np->dev are done outside of the rtnl lock (patch 01).
The second patch fixes a deadlock in netconsole and does a trivial comment
style fix.

v2: fix the function style in patch 01

Best regards,
 Nikolay Aleksandrov

Nikolay Aleksandrov (2):
  netpoll: fix NULL pointer dereference in netpoll_cleanup
  netconsole: fix a deadlock with rtnl and netconsole's mutex

 drivers/net/netconsole.c | 5 +----
 net/core/netpoll.c       | 9 ++++-----
 2 files changed, 5 insertions(+), 9 deletions(-)

-- 
1.8.1.4
