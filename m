From: David Miller <davem@davemloft.net>
Subject: [PATCH]: quelch ppp generic warnings...
Date: Wed, 19 Aug 2009 13:56:55 -0700 (PDT)
Message-ID: <20090819.135655.13311240.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36018
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752129AbZHSU4n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Aug 2009 16:56:43 -0400
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 91E22C8C1B2
	for <netdev@vger.kernel.org>; Wed, 19 Aug 2009 13:56:55 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


I just commited this to net-next-2.6

ppp_generic: Help GCC see that 'flen' is always initialized.

It's too stupid to see that we always set flen to something
before we use it in ppp_mp_explode():

drivers/net/ppp_generic.c: In function 'ppp_push':
drivers/net/ppp_generic.c:1314: warning: 'flen' may be used uninitialized in this function
drivers/net/ppp_generic.c:1314: note: 'flen' was declared here

This started warning after commit a53a8b56827cc429c6d9f861ad558beeb5f6103f
("ppp: fix lost fragments in ppp_mp_explode() (resubmit)")

So just put an explicit unconditional initialization there to
hush it up.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 drivers/net/ppp_generic.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ppp_generic.c b/drivers/net/ppp_generic.c
index 7dd0868..35be2e8 100644
--- a/drivers/net/ppp_generic.c
+++ b/drivers/net/ppp_generic.c
@@ -1431,6 +1431,7 @@ static int ppp_mp_explode(struct ppp *ppp, struct sk_buff *skb)
 		*otherwise divide it according to the speed
 		*of the channel we are going to transmit on
 		*/
+		flen = len;
 		if (nfree > 0) {
 			if (pch->speed == 0) {
 				flen = totlen/nfree	;
-- 
1.6.3.4

