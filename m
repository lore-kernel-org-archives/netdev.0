From: Vlad Yasevich <vyasevic@redhat.com>
Subject: [PATCH 0/2] Add suppport for sync of hw addresses to multiple devices.
Date: Mon, 15 Apr 2013 15:09:55 -0400
Message-ID: <1366052997-12435-1-git-send-email-vyasevic@redhat.com>
Cc: Vlad Yasevich <vyasevic@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:15760 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932892Ab3DOTJ6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 15 Apr 2013 15:09:58 -0400
Received: from int-mx01.intmail.prod.int.phx2.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id r3FJ9w8I007180
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Mon, 15 Apr 2013 15:09:58 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Current dev_[uc|mc]_addr_sync() API currently correctly syncs the
addresses to the first device.  Any subsequent calls to sync will
not do anything since the synched variable will be set.  This
variable is used as an optimization to skip over addresses that have
been synched.

There are some devices (ex: team) that attempt to do the above.  There
is other work in progress that needs to above to work corretly.

The short series introduces dev_[uc|mc]_addr_synch_multiple() that
allows multiple calls to sync to multiple different devices.  Original
API is left alone and still has the limitation.

Vlad Yasevich (2):
  net: add dev_uc_sync_multiple() and dev_mc_sync_multiple() api
  team:  Use new sync_multiple api to sync devices adressess.

 drivers/net/team/team.c   |    4 +-
 include/linux/netdevice.h |    3 +
 net/core/dev_addr_lists.c |  210 ++++++++++++++++++++++++++++++++++++---------
 3 files changed, 173 insertions(+), 44 deletions(-)

-- 
1.7.7.6
