From: Weiping Pan <wpan@redhat.com>
Subject: [PATCH net 0/3] correct behavior when modify primary via sysfs
Date: Mon, 11 Jun 2012 17:00:19 +0800
Message-ID: <cover.1339404887.git.wpan@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:56096 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752286Ab2FKIzs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Jun 2012 04:55:48 -0400
Received: from int-mx10.intmail.prod.int.phx2.redhat.com (int-mx10.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id q5B8tj8U027368
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Mon, 11 Jun 2012 04:55:45 -0400
Received: from localhost.localdomain.com (dhcp-16-141.nay.redhat.com [10.66.16.141] (may be forged))
	by int-mx10.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id q5B8thXP012130
	for <netdev@vger.kernel.org>; Mon, 11 Jun 2012 04:55:44 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There is a problem that when we set primary slave with module parameters,
bond will always use this primary slave as active slave.

But when we modify primary slave via sysfs, it will call
bond_should_change_active() and take into account
primary_reselect.

And I think we should use the new primary slave as the new active slave
regardless of the value of primary_reselect.
Thus the behavior is the same with module parameters and meets the
administrator's expectation.

Weiping Pan (3):
  bonding:record primary when modify it via sysfs
  bonding:check mode when modify primary_reselect
  bonding:force to use primary slave

 drivers/net/bonding/bond_sysfs.c |   16 ++++++++++++++--
 1 files changed, 14 insertions(+), 2 deletions(-)

-- 
1.7.4
