From: Chris Wright <chrisw@sous-sol.org>
Subject: [patch 04/39] [PATCH] [BRIDGE]: netfilter missing symbol has_bridge_parent
Date: Mon, 27 Feb 2006 14:32:04 -0800
Message-ID: <20060227223321.042696000@sorel.sous-sol.org>
References: <20060227223200.865548000@sorel.sous-sol.org>
Cc: Justin Forbes <jmforbes@linuxtx.org>,
	Zwane Mwaikambo <zwane@arm.linux.org.uk>,
	"Theodore Ts'o" <tytso@mit.edu>,
	Randy Dunlap <rdunlap@xenotime.net>,
	Dave Jones <davej@redhat.com>,
	Chuck Wolber <chuckw@quantumlinux.com>, torvalds@osdl.org,
	akpm@osdl.org, alan@lxorguk.ukuu.org.uk,
	Horms <horms@verge.net.au>, wensong@linux-vs.org,
	netdev@vger.kernel.org, ja@ssi.bg,
	"David S. Miller" <davem@davemloft.net>,
	Stephen Hemminger <shemminger@osdl.org>,
	Greg Kroah-Hartman <gregkh@suse.de>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751846AbWB0Wut@vger.kernel.org>
To: linux-kernel@vger.kernel.org, stable@kernel.org,
	Bernard Pidoux <pidoux@ccr.jussieu.fr>
Content-Disposition: inline; filename=netfilter-missing-symbol.patch
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

-stable review patch.  If anyone has any objections, please let us know.
------------------

5dce971acf2ae20c80d5e9d1f6bbf17376870911 in Linus' tree,
otherwise known as bridge-netfilter-races-on-device-removal.patch in
2.5.15.4 removed has_bridge_parent, however this symbol is still
called with NETFILTER_DEBUG is enabled.

This patch uses the already seeded realoutdev value to detect if a parent
exists, and if so, the value of the parent.

Signed-Off-By: Horms <horms@verge.net.au>
Acked-by: Stephen Hemminger <shemminger@osdl.org>
Signed-off-by: Chris Wright <chrisw@sous-sol.org>
Signed-off-by: Greg Kroah-Hartman <gregkh@suse.de>
---

 net/bridge/br_netfilter.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

--- linux-2.6.15.4.orig/net/bridge/br_netfilter.c
+++ linux-2.6.15.4/net/bridge/br_netfilter.c
@@ -794,8 +794,8 @@ static unsigned int br_nf_post_routing(u
 print_error:
 	if (skb->dev != NULL) {
 		printk("[%s]", skb->dev->name);
-		if (has_bridge_parent(skb->dev))
-			printk("[%s]", bridge_parent(skb->dev)->name);
+		if (realoutdev)
+			printk("[%s]", realoutdev->name);
 	}
 	printk(" head:%p, raw:%p, data:%p\n", skb->head, skb->mac.raw,
 					      skb->data);

--
