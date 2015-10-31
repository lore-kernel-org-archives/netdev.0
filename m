From: Mahesh Bandewar <maheshb@google.com>
Subject: [PATCH next 1/3] bonding: Simplify __get_duplex function.
Date: Sat, 31 Oct 2015 12:45:00 -0700
Message-ID: <1446320700-38613-1-git-send-email-maheshb@google.com>
Cc: Mahesh Bandewar <maheshb@google.com>,
	David Decotigny <decot@google.com>,
	netdev <netdev@vger.kernel.org>
To: Jay Vosburgh <j.vosburgh@gmail.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	Veaceslav Falico <vfalico@gmail.com>,
	Nikolay Aleksandrov <nikolay@redhat.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:32841 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751075AbbJaTpH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 31 Oct 2015 15:45:07 -0400
Received: by padhy1 with SMTP id hy1so100002628pad.0
        for <netdev@vger.kernel.org>; Sat, 31 Oct 2015 12:45:06 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eliminate 'else' clause by simply initializing variable

Signed-off-by: Mahesh Bandewar <maheshb@google.com>
---
 drivers/net/bonding/bond_3ad.c | 6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/drivers/net/bonding/bond_3ad.c b/drivers/net/bonding/bond_3ad.c
index 3c45358844eb..3a17fd207ec6 100644
--- a/drivers/net/bonding/bond_3ad.c
+++ b/drivers/net/bonding/bond_3ad.c
@@ -327,14 +327,12 @@ static u16 __get_link_speed(struct port *port)
 static u8 __get_duplex(struct port *port)
 {
 	struct slave *slave = port->slave;
-	u8 retval;
+	u8 retval = 0x0;
 
 	/* handling a special case: when the configuration starts with
 	 * link down, it sets the duplex to 0.
 	 */
-	if (slave->link != BOND_LINK_UP) {
-		retval = 0x0;
-	} else {
+	if (slave->link == BOND_LINK_UP) {
 		switch (slave->duplex) {
 		case DUPLEX_FULL:
 			retval = 0x1;
-- 
2.6.0.rc2.230.g3dd15c0
