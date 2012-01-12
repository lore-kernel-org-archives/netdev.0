From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [BUG] commit a9b3cd7f32 is a mess
Date: Thu, 12 Jan 2012 14:56:43 +0100
Message-ID: <1326376603.2950.14.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:58851 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753630Ab2ALN4r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Jan 2012 08:56:47 -0500
Received: by werm1 with SMTP id m1so1352954wer.19
        for <netdev@vger.kernel.org>; Thu, 12 Jan 2012 05:56:46 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit a9b3cd7f32 (rcu: convert uses of rcu_assign_pointer(x, NULL) to
RCU_INIT_POINTER) is complete garbage.

Real content of this commit doesnt reflect Changelog claim.

I found this while trying to understand a 3.2 regression in IGMP code.

	iml->sfmode = MCAST_EXCLUDE;
-	rcu_assign_pointer(inet->mc_list, iml);
+	RCU_INIT_POINTER(inet->mc_list, iml);

Obviously iml is not NULL here.

Please Paul dont Ack a patch only reading the Changelog.

I'll make a patch to revert all non NULL uses.
