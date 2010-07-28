From: <gregkh@suse.de>
Subject: Patch "IPv6: keep route for tentative address" has been added to the 2.6.34-stable tree
Date: Tue, 27 Jul 2010 17:24:57 -0700
Message-ID: <12802766972168@site>
References: <20100524113118.47cc9852@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=ANSI_X3.4-1968
Content-Transfer-Encoding: 8bit
Cc: <stable@kernel.org>, <stable-commits@vger.kernel.org>
To: shemminger@vyatta.com, davem@davemloft.net,
	emils.tantilov@gmail.com, emil.s.tantilov@intel.com,
	gregkh@suse.de, greg@kroah.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from kroah.org ([198.145.64.141]:57031 "EHLO coco.kroah.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751173Ab0G1Adu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Jul 2010 20:33:50 -0400
In-Reply-To: <20100524113118.47cc9852@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This is a note to let you know that I've just added the patch titled

    IPv6: keep route for tentative address

to the 2.6.34-stable tree which can be found at:
    http://www.kernel.org/git/?p=linux/kernel/git/stable/stable-queue.git;a=summary

The filename of the patch is:
    ipv6-keep-route-for-tentative-address.patch
and it can be found in the queue-2.6.34 subdirectory.

If you, or anyone else, feels it should not be added to the stable tree,
please let <stable@kernel.org> know about it.


>From shemminger@vyatta.com  Tue Jul 27 16:56:59 2010
From: Stephen Hemminger <shemminger@vyatta.com>
Date: Mon, 24 May 2010 11:31:18 -0700
Subject: IPv6: keep route for tentative address
To: Emil S Tantilov <emils.tantilov@gmail.com>
Cc: NetDev <netdev@vger.kernel.org>, stable@kernel.org, Greg KH <greg@kroah.com>, "David S. Miller" <davem@davemloft.net>, "Tantilov, Emil S" <emil.s.tantilov@intel.com>
Message-ID: <20100524113118.47cc9852@nehalam>

From: Stephen Hemminger <shemminger@vyatta.com>

(cherry picked from commit 93fa159abe50d3c55c7f83622d3f5c09b6e06f4b)

Recent changes preserve IPv6 address when link goes down (good).
But would cause address to point to dead dst entry (bad).
The simplest fix is to just not delete route if address is
being held for later use.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
Signed-off-by: David S. Miller <davem@davemloft.net>
Signed-off-by: Greg Kroah-Hartman <gregkh@suse.de>

---
 net/ipv6/addrconf.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -4047,7 +4047,8 @@ static void __ipv6_ifa_notify(int event,
 			addrconf_leave_anycast(ifp);
 		addrconf_leave_solict(ifp->idev, &ifp->addr);
 		dst_hold(&ifp->rt->u.dst);
-		if (ip6_del_rt(ifp->rt))
+
+		if (ifp->dead && ip6_del_rt(ifp->rt))
 			dst_free(&ifp->rt->u.dst);
 		break;
 	}


Patches currently in stable-queue which might be from shemminger@vyatta.com are

queue-2.6.34/sky2-restore-multicast-after-restart.patch
queue-2.6.34/ipv6-keep-route-for-tentative-address.patch
queue-2.6.34/ipv6-only-notify-protocols-if-address-is-completely-gone.patch
queue-2.6.34/ipv6-fix-null-reference-in-proxy-neighbor-discovery.patch
queue-2.6.34/bridge-fdb-cleanup-runs-too-often.patch
