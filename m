From: <gregkh@suse.de>
Subject: Patch "IPv6: only notify protocols if address is completely gone" has been added to the 2.6.34-stable tree
Date: Tue, 27 Jul 2010 17:25:00 -0700
Message-ID: <12802767002169@site>
References: <20100524113300.2ef38e12@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=ANSI_X3.4-1968
Content-Transfer-Encoding: 8bit
Cc: <stable@kernel.org>, <stable-commits@vger.kernel.org>
To: shemminger@vyatta.com, davem@davemloft.net,
	emils.tantilov@gmail.com, emil.s.tantilov@intel.com,
	gregkh@suse.de, greg@kroah.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from kroah.org ([198.145.64.141]:57040 "EHLO coco.kroah.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752658Ab0G1Adz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Jul 2010 20:33:55 -0400
In-Reply-To: <20100524113300.2ef38e12@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This is a note to let you know that I've just added the patch titled

    IPv6: only notify protocols if address is completely gone

to the 2.6.34-stable tree which can be found at:
    http://www.kernel.org/git/?p=linux/kernel/git/stable/stable-queue.git;a=summary

The filename of the patch is:
    ipv6-only-notify-protocols-if-address-is-completely-gone.patch
and it can be found in the queue-2.6.34 subdirectory.

If you, or anyone else, feels it should not be added to the stable tree,
please let <stable@kernel.org> know about it.


>From shemminger@vyatta.com  Tue Jul 27 16:57:29 2010
From: Stephen Hemminger <shemminger@vyatta.com>
Date: Mon, 24 May 2010 11:33:00 -0700
Subject: IPv6: only notify protocols if address is completely gone
To: Emil S Tantilov <emils.tantilov@gmail.com>, "David S. Miller" <davem@davemloft.net>, Greg KH <greg@kroah.com>
Cc: NetDev <netdev@vger.kernel.org>, "Tantilov, Emil S" <emil.s.tantilov@intel.com>, stable@kernel.org
Message-ID: <20100524113300.2ef38e12@nehalam>

From: Stephen Hemminger <shemminger@vyatta.com>

(cherry picked from commit 8595805aafc8b077e01804c9a3668e9aa3510e89)

The notifier for address down should only be called if address is completely
gone, not just being marked as tentative on link transition. The code
in net-next would case bonding/sctp/s390 to see address disappear on link
down, but they would never see it reappear on link up.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
Signed-off-by: David S. Miller <davem@davemloft.net>
Signed-off-by: Greg Kroah-Hartman <gregkh@suse.de>

---
 net/ipv6/addrconf.c |    4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -2729,7 +2729,9 @@ static int addrconf_ifdown(struct net_de
 		write_unlock_bh(&idev->lock);
 
 		__ipv6_ifa_notify(RTM_DELADDR, ifa);
-		atomic_notifier_call_chain(&inet6addr_chain, NETDEV_DOWN, ifa);
+		if (ifa->dead)
+			atomic_notifier_call_chain(&inet6addr_chain,
+						   NETDEV_DOWN, ifa);
 		in6_ifa_put(ifa);
 
 		write_lock_bh(&idev->lock);


Patches currently in stable-queue which might be from shemminger@vyatta.com are

queue-2.6.34/sky2-restore-multicast-after-restart.patch
queue-2.6.34/ipv6-keep-route-for-tentative-address.patch
queue-2.6.34/ipv6-only-notify-protocols-if-address-is-completely-gone.patch
queue-2.6.34/ipv6-fix-null-reference-in-proxy-neighbor-discovery.patch
queue-2.6.34/bridge-fdb-cleanup-runs-too-often.patch
