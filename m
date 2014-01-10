From: Veaceslav Falico <vfalico@redhat.com>
Subject: [PATCH v3 net-next 0/3] bonding: fix bond_3ad RCU usage
Date: Fri, 10 Jan 2014 10:18:40 +0100
Message-ID: <1389345523-5497-1-git-send-email-vfalico@redhat.com>
Cc: dingtianhong@huawei.com, Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	Veaceslav Falico <vfalico@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:56125 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751343AbaAJJXA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 Jan 2014 04:23:00 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

While digging through bond_3ad.c I've found that the RCU usage there is
just wrong - it's used as a kind of mutex/spinlock instead of RCU.

v2->v3: make bond_3ad_set_carrier() use RCU read lock for the whole
function, so that all other functions will be protected by RCU as well.
This way we can use _rcu variants everywhere.

v1->v2: use generic primitives instead of _rcu ones cause we can hold RTNL
lock without RCU one, which is still safe.

This patchset is on top of bond_3ad.c cleanup:
http://www.spinics.net/lists/netdev/msg265447.html

CC: dingtianhong@huawei.com
CC: Jay Vosburgh <fubar@us.ibm.com>
CC: Andy Gospodarek <andy@greyhouse.net>
CC: netdev@vger.kernel.org
Signed-off-by: Veaceslav Falico <vfalico@redhat.com>
