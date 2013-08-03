From: Veaceslav Falico <vfalico@redhat.com>
Subject: [PATCH net-next 0/2] bonding: cleanup arp_interval related time math
Date: Sat,  3 Aug 2013 03:50:34 +0200
Message-ID: <1375494636-7947-1-git-send-email-vfalico@redhat.com>
Cc: Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	Veaceslav Falico <vfalico@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:51719 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754249Ab3HCBuY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 2 Aug 2013 21:50:24 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Current implementation uses heavily time_in_range() with similar, lengthy,
params. By moving it to a separate function we can simplify the code a lot.

First patch saves a possibly heavy slave_last_rx() function to a variable
and uses the variable in the calculation.

Second patch introduces helper function bond_time_in_interval() to make the
arp_interval math and uses it instead of lengthy time_in_range() calls.

Both of them don't change anything logically and in terms of speed and are
purely cleanup patches.

CC: Jay Vosburgh <fubar@us.ibm.com>
CC: Andy Gospodarek <andy@greyhouse.net>
Signed-off-by: Veaceslav Falico <vfalico@redhat.com>

 drivers/net/bonding/bond_main.c |   88 +++++++++++++++------------------------
 1 files changed, 34 insertions(+), 54 deletions(-)
