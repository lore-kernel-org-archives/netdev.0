From: Veaceslav Falico <vfalico@gmail.com>
Subject: [PATCH net-next 0/2] bonding: fix enslaving a dev without mtu setting support
Date: Wed, 21 May 2014 17:41:59 +0200
Message-ID: <1400686921-5698-1-git-send-email-vfalico@gmail.com>
Cc: Jay Vosburgh <j.vosburgh@gmail.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	Veaceslav Falico <vfalico@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:50111 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751137AbaEUPqp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 May 2014 11:46:45 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

With the introduction of bond_free_slave() we need to have slave->bond
populated before calling it, however if the dev_mtu_set(slave, mtu) fails,
we call bond_free_slave() before actually setting slave->bond, and thus
we'll panic.

Fix this by populating slave->bond (and ->dev, it seems appropriate) as
early as possible.

Also, remove a harmful check for NULL in bond_get_bond_by_slave(), as it's
only hiding the real problem and making it harder to debug.

CC: Jay Vosburgh <j.vosburgh@gmail.com>
CC: Andy Gospodarek <andy@greyhouse.net>
CC: netdev@vger.kernel.org
Signed-off-by: Veaceslav Falico <vfalico@gmail.com>

---
 drivers/net/bonding/bond_main.c | 4 ++--
 drivers/net/bonding/bonding.h   | 2 --
 2 files changed, 2 insertions(+), 4 deletions(-)
