From: Veaceslav Falico <vfalico@redhat.com>
Subject: [PATCH v2 net-next 0/3] bonding: fix bond_3ad RCU usage
Date: Thu,  9 Jan 2014 12:20:22 +0100
Message-ID: <1389266425-28365-1-git-send-email-vfalico@redhat.com>
Cc: Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	Veaceslav Falico <vfalico@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:32535 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751678AbaAILYl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Jan 2014 06:24:41 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

While digging through bond_3ad.c I've found that the RCU usage there is
just wrong - it's used as a kind of mutex/spinlock instead of RCU.

v1->v2: use generic primitives instead of _rcu ones cause we can hold RTNL
lock without RCU one, which is still safe.

This patchset is on top of bond_3ad.c cleanup:
http://www.spinics.net/lists/netdev/msg265447.html

CC: Jay Vosburgh <fubar@us.ibm.com>
CC: Andy Gospodarek <andy@greyhouse.net>
CC: netdev@vger.kernel.org
Signed-off-by: Veaceslav Falico <vfalico@redhat.com>
