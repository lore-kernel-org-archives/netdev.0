From: Jiri Pirko <jpirko@redhat.com>
Subject: Re: [PATCH 1/3] vlan: Do not support clearing VLAN_FLAG_REORDER_HDR
Date: Thu, 9 Jun 2011 13:00:58 +0200
Message-ID: <20110609110057.GB11005@minipsycho.brq.redhat.com>
References: <BANLkTikSKiYoiOLB=i7qjR0N--CAQ2dHWw@mail.gmail.com>
 <20110521072925.GA2588@jirka.orion>
 <BANLkTinZUATEjBij+rwBTn=n-Tau5qHPWw@mail.gmail.com>
 <4DD7BB61.9050200@gmail.com>
 <BANLkTinqFJa-B7E7tonzOKGV4etZHUkUug@mail.gmail.com>
 <4DD87C25.4030701@gmail.com>
 <20110522062915.GA2611@jirka.orion>
 <m17h9jp7js.fsf@fess.ebiederm.org>
 <BANLkTi=4JJa-J-p_JbY1PfooT75KfSB4uA@mail.gmail.com>
 <m1ei3qjzix.fsf_-_@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	Nicolas de =?iso-8859-1?Q?Peslo=FCan?=
	<nicolas.2p.debian@gmail.com>, Changli Gao <xiaosuo@gmail.com>,
	netdev@vger.kernel.org, shemminger@linux-foundation.org,
	kaber@trash.net, fubar@us.ibm.com, eric.dumazet@gmail.com,
	andy@greyhouse.net, Jesse Gross <jesse@nicira.com>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:26755 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754720Ab1FILBJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Jun 2011 07:01:09 -0400
Content-Disposition: inline
In-Reply-To: <m1ei3qjzix.fsf_-_@fess.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

How about to drop this patch and silently ignore the flag? That would
feel the same for user who is setting it.

Sun, May 22, 2011 at 09:39:18PM CEST, ebiederm@xmission.com wrote:
>
>Simplify the vlan handling code by not supporing clearing of
>VLAN_FLAG_REORDER_HDR.  Which means we always make the vlan handling
>code strip the vlan header from the packets, and always insert the vlan
>header when transmitting packets.
>
>Not stripping the vlan header has alwasy been broken in combination with
>vlan hardware accelleration.  Now that we are making everything look
>like accelerated vlan handling not stripping the vlan header is always
>broken.
>
>I don't think anyone actually cares so simply stop supporting the broken
>case.
>
>Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
>---
> net/8021q/vlan_dev.c     |    3 +--
> net/8021q/vlan_netlink.c |    4 +---
> 2 files changed, 2 insertions(+), 5 deletions(-)
>
>diff --git a/net/8021q/vlan_dev.c b/net/8021q/vlan_dev.c
>index f247f5b..20629fe 100644
>--- a/net/8021q/vlan_dev.c
>+++ b/net/8021q/vlan_dev.c
>@@ -242,8 +242,7 @@ int vlan_dev_change_flags(const struct net_device *dev, u32 flags, u32 mask)
> 	struct vlan_dev_info *vlan = vlan_dev_info(dev);
> 	u32 old_flags = vlan->flags;
> 
>-	if (mask & ~(VLAN_FLAG_REORDER_HDR | VLAN_FLAG_GVRP |
>-		     VLAN_FLAG_LOOSE_BINDING))
>+	if (mask & ~(VLAN_FLAG_GVRP | VLAN_FLAG_LOOSE_BINDING))
> 		return -EINVAL;
> 
> 	vlan->flags = (old_flags & ~mask) | (flags & mask);
>diff --git a/net/8021q/vlan_netlink.c b/net/8021q/vlan_netlink.c
>index be9a5c1..a638a4c 100644
>--- a/net/8021q/vlan_netlink.c
>+++ b/net/8021q/vlan_netlink.c
>@@ -59,9 +59,7 @@ static int vlan_validate(struct nlattr *tb[], struct nlattr *data[])
> 	}
> 	if (data[IFLA_VLAN_FLAGS]) {
> 		flags = nla_data(data[IFLA_VLAN_FLAGS]);
>-		if ((flags->flags & flags->mask) &
>-		    ~(VLAN_FLAG_REORDER_HDR | VLAN_FLAG_GVRP |
>-		      VLAN_FLAG_LOOSE_BINDING))
>+		if (flags->mask & ~(VLAN_FLAG_GVRP | VLAN_FLAG_LOOSE_BINDING))
> 			return -EINVAL;
> 	}
> 
>-- 
>1.7.5.1.217.g4e3aa
>
