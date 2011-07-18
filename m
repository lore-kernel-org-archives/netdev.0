From: David Miller <davem@davemloft.net>
Subject: Re: [Bugme-new] [Bug 39252] New: [r8169] PPPoE connections don't
 work if a custom MAC address is assigned
Date: Mon, 18 Jul 2011 11:50:20 -0700 (PDT)
Message-ID: <20110718.115020.1016628731150912638.davem@davemloft.net>
References: <bug-39252-10286@https.bugzilla.kernel.org/>
	<20110713161345.82e254de.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bugme-daemon@bugzilla.kernel.org,
	t.artem@mailcity.com, mostrows@earthlink.net
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:49110 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751258Ab1GRSuh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Jul 2011 14:50:37 -0400
In-Reply-To: <20110713161345.82e254de.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Morton <akpm@linux-foundation.org>
Date: Wed, 13 Jul 2011 16:13:45 -0700

>> https://bugzilla.kernel.org/show_bug.cgi?id=39252
>> 
>>            Summary: [r8169] PPPoE connections don't work if a custom MAC
>>                     address is assigned
 ...
>> Description of problem: if I assign a custom MAC address to my onboard NIC,
>> then I cannot establish PPPoE connections, and even `pppoe -A` command doesn't
>> return any PPPoE access concentrators.

Since you seem to be creating your PPPoE connections _after_ changing
the MAC, the following shouldn't matter, but for the cases where
PPPoE connections already exist we do need this kind of change.

Again, I don't expect this to fix the bug, and I believe that it's
some r8169 specific issue.  Although, it might.

--------------------
pppoe: Must flush connections when MAC address changes too.

Kernel bugzilla: 39252

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 drivers/net/pppoe.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/drivers/net/pppoe.c b/drivers/net/pppoe.c
index 718879b..bc9a4bb 100644
--- a/drivers/net/pppoe.c
+++ b/drivers/net/pppoe.c
@@ -348,8 +348,9 @@ static int pppoe_device_event(struct notifier_block *this,
 
 	/* Only look at sockets that are using this specific device. */
 	switch (event) {
+	case NETDEV_CHANGEADDR:
 	case NETDEV_CHANGEMTU:
-		/* A change in mtu is a bad thing, requiring
+		/* A change in mtu or address is a bad thing, requiring
 		 * LCP re-negotiation.
 		 */
 
-- 
1.7.6

