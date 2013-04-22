From: Chen Gang <gang.chen@asianux.com>
Subject: [PATCH] Net: mac802154: comparing issue by type cast, finding by
 EXTRA_CFLAGS=-W
Date: Mon, 22 Apr 2013 14:41:11 +0800
Message-ID: <5174DB87.3010908@asianux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	linux-zigbee-devel@lists.sourceforge.net,
	netdev <netdev@vger.kernel.org>
To: alex.bluesman.smirnov@gmail.com, dbaryshkov@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from intranet.asianux.com ([58.214.24.6]:50418 "EHLO
	intranet.asianux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753212Ab3DVGl4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Apr 2013 02:41:56 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


  need change ~(u8)0 to 0xff,
  or in mac802154_wpan_xmit(), "u8 chan" will never == MAC802154_CHAN_NONE

  find it by "make EXTRA_CFLAGS=-W"
    net/mac802154/wpan.c:325:2: warning: comparison is always false
    due to limited range of data type [-Wtype-limits]

  related unit test:
    cc -Wall -O2 -o test test.c
    ./test
    will output 'different'

    (after use '0xff' instead of '~(u8)0', it will output 'equal')

-----------------------test code begin--------------------------------

#include <stdio.h>

typedef unsigned char u8;

int main()
{
	u8 uc = 0xff;

	if (uc == ~(u8)0)
		printf("\nequal\n");
	else
		printf("\ndifferent\n");

	return 0;
}

-----------------------test code end----------------------------------


Signed-off-by: Chen Gang <gang.chen@asianux.com>
---
 net/mac802154/mac802154.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/mac802154/mac802154.h b/net/mac802154/mac802154.h
index 5c9e021..c59309f 100644
--- a/net/mac802154/mac802154.h
+++ b/net/mac802154/mac802154.h
@@ -88,7 +88,7 @@ struct mac802154_sub_if_data {
 
 #define mac802154_to_priv(_hw)	container_of(_hw, struct mac802154_priv, hw)
 
-#define MAC802154_CHAN_NONE		(~(u8)0) /* No channel is assigned */
+#define MAC802154_CHAN_NONE		(0xff) /* No channel is assigned */
 
 extern struct ieee802154_reduced_mlme_ops mac802154_mlme_reduced;
 extern struct ieee802154_mlme_ops mac802154_mlme_wpan;
-- 
1.7.7.6
