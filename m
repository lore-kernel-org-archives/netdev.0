From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [PATCH] bonding: simplify code and get rid of warning
Date: Wed, 20 Feb 2008 08:57:56 -0800
Message-ID: <21522.1203526676@death>
References: <20080218210426.022bbe36@extreme>
Cc: bonding-devel@lists.sourceforge.net, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e1.ny.us.ibm.com ([32.97.182.141]:47629 "EHLO e1.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932948AbYBTQ6D (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Feb 2008 11:58:03 -0500
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e1.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id m1KGvxiO008789
	for <netdev@vger.kernel.org>; Wed, 20 Feb 2008 11:57:59 -0500
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m1KGvxXR241122
	for <netdev@vger.kernel.org>; Wed, 20 Feb 2008 11:57:59 -0500
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m1KGvxsQ006572
	for <netdev@vger.kernel.org>; Wed, 20 Feb 2008 11:57:59 -0500
In-reply-to: <20080218210426.022bbe36@extreme> 
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger <shemminger@vyatta.com> wrote:

>Get rid of warning and simplify code that looks up vlan tag.
>No need to get tag, then copy it. Also no need for a local status
>variable.

	Granted, the current code is suboptimal, but I don't see any
warnings compiling this (gcc 4.1.2).  What are you getting?

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com


>Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
>---
>Patch against current 2.6.25 version.
>
>--- a/drivers/net/bonding/bond_alb.c	2008-02-18 20:58:53.000000000 -0800
>+++ b/drivers/net/bonding/bond_alb.c	2008-02-18 21:01:10.000000000 -0800
>@@ -678,12 +678,8 @@ static struct slave *rlb_choose_channel(
> 		}
>
> 		if (!list_empty(&bond->vlan_list)) {
>-			unsigned short vlan_id;
>-			int res = vlan_get_tag(skb, &vlan_id);
>-			if (!res) {
>+			if (!vlan_get_tag(skb, &client_info->vlan_id))
> 				client_info->tag = 1;
>-				client_info->vlan_id = vlan_id;
>-			}
> 		}
>
> 		if (!client_info->assigned) {
>--
>To unsubscribe from this list: send the line "unsubscribe netdev" in
>the body of a message to majordomo@vger.kernel.org
>More majordomo info at  http://vger.kernel.org/majordomo-info.html
