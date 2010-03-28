From: Jan Engelhardt <jengelh@medozas.de>
Subject: Re: Seeing new kernel unaligned access messages in linux-next on
 ia64
Date: Sun, 28 Mar 2010 01:11:13 +0100 (CET)
Message-ID: <alpine.LSU.2.01.1003280107420.14977@obet.zrqbmnf.qr>
References: <alpine.LSU.2.01.1003250014400.16715@obet.zrqbmnf.qr> <20100324.203249.97351120.davem@davemloft.net> <alpine.LSU.2.01.1003271313230.2740@obet.zrqbmnf.qr> <20100327.163730.179928738.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: schwab@linux-m68k.org, tony.luck@intel.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from borg.medozas.de ([188.40.89.202]:58846 "EHLO borg.medozas.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754027Ab0C1ALP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 27 Mar 2010 20:11:15 -0400
In-Reply-To: <20100327.163730.179928738.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sunday 2010-03-28 00:37, David Miller wrote:
>
>> net: fix unaligned access in IFLA_STATS64
>
>Applied to net-next-2.6, thanks Jan.
>
>Hey, don't we need some adjustments to if_nlmsg_size()?  I don't see
>it accounting for IFLA_STATS64/"struct rtnl_link_stats64" there.

If I am not mistaken, the answer is "not strictly". But of course it's 
nicer if we don't need to realloc just because we were too conservative 
in the initial calculation.


git://dev.medozas.de/linux net

parent c5c57d7c7837858aa499610a3ee760b39f1de937 (v2.6.34-rc1-1276-gc5c57d7)
commit 305876b7c1c720db30239d08d56b3a058d56aa21
Author: Jan Engelhardt <jengelh@medozas.de>
Date:   Sun Mar 28 01:03:32 2010 +0100

net: increase preallocated size of nlmsg to accomodate for IFLA_STATS64

When more data is stuffed into an nlmsg than initially projected, an
extra allocation needs to be done. Reserve enough for IFLA_STATS64 so
that this does not to needlessy happen.

Signed-off-by: Jan Engelhardt <jengelh@medozas.de>
---
 net/core/rtnetlink.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index ed0766f..bf919b6 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -653,6 +653,7 @@ static inline size_t if_nlmsg_size(const struct net_device *dev)
 	       + nla_total_size(IFNAMSIZ) /* IFLA_QDISC */
 	       + nla_total_size(sizeof(struct rtnl_link_ifmap))
 	       + nla_total_size(sizeof(struct rtnl_link_stats))
+	       + nla_total_size(sizeof(struct rtnl_link_stats64))
 	       + nla_total_size(MAX_ADDR_LEN) /* IFLA_ADDRESS */
 	       + nla_total_size(MAX_ADDR_LEN) /* IFLA_BROADCAST */
 	       + nla_total_size(4) /* IFLA_TXQLEN */
-- 
# Created with git-export-patch
