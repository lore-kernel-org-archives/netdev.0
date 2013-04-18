From: Nikolay Aleksandrov <nikolay@redhat.com>
Subject: [PATCHv2 0/5] bonding: enslave and locking bug fixes
Date: Thu, 18 Apr 2013 19:33:33 +0200
Message-ID: <1366306418-3661-1-git-send-email-nikolay@redhat.com>
Cc: andy@greyhouse.net, fubar@us.ibm.com, davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:45189 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S966799Ab3DRRgz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Apr 2013 13:36:55 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,
This patch-set fixes mainly bugs on enslave failure and one occasion
of a needed locking. The patches are:

	1. On enslave failure mc addresses are not flushed from the slave
	2. On enslave failure vlans are not cleaned up from the slave
	3. On enslave failure the bond's primary and curr_active_slave
	   are not cleaned up (which might result in use of freed memory)
	4. On enslave failure netpoll is not disabled which might result in
	   a memory leak
	5. In bond_mc_swap() the bond's mc addr list is walked without
	   netif_addr_lock, since it can be called without rtnl, add it

v2: patch 01 - fix log message and remove unnecessary code move

Best regards,
 Nik

Nikolay Aleksandrov (5):
  bonding: mc addresses don't get deleted on enslave failure
  bonding: vlans don't get deleted on enslave failure
  bonding: primary_slave & curr_active_slave are not cleaned on enslave
    failure
  bonding: disable netpoll on enslave failure
  bonding: in bond_mc_swap() bond's mc addr list is walked without lock

 drivers/net/bonding/bond_main.c | 27 +++++++++++++++++++++++----
 1 file changed, 23 insertions(+), 4 deletions(-)

-- 
1.8.1.4
