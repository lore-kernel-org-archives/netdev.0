From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next 0/5] sched, cbq: remove OVL_STRATEGY/POLICE
 support
Date: Wed, 08 Jun 2016 23:59:11 -0700 (PDT)
Message-ID: <20160608.235911.2037615285346040712.davem@davemloft.net>
References: <1465424863-18456-1-git-send-email-fw@strlen.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: fw@strlen.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42163 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934155AbcFIG7P (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jun 2016 02:59:15 -0400
In-Reply-To: <1465424863-18456-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>
Date: Thu,  9 Jun 2016 00:27:38 +0200

> iproute2 does not implement any options that result in the
> TCA_CBQ_OVL_STRATEGY/TCA_CBQ_POLICE attributes being set/used.
> 
> This series removes these two attributes from cbq and makes kernel reject
>  them via EOPNOTSUPP in case they are present.
> 
> The two followup changes then remove several features from qdisc
> infrastructure that are then no longer used/needed.  These are:
>  - The 'drop' method provided by most qdiscs
>  - the 'reshape_fail' function used by some qdiscs
>  - the __parent member in struct Qdisc
> 
> I tested this with allmod and allyesconfig builds and also with
> a brief cbq script:
> 
>   tc qdisc add dev eth0 root handle 1:0 cbq bandwidth 10Mbit avpkt 1000 cell 8
>   tc class add dev eth0 parent 1:0 classid 1:1 est 1sec 8sec cbq bandwidth 10Mbit rate 5Mbit prio 1 allot 1514 maxburst 20 cell 8 avpkt 1000 bounded split 1:0 defmap 3f
>   tc class add dev eth0 parent 1:0 classid 1:2 est 1sec 8sec cbq bandwidth 10Mbit rate 5Mbit prio 1 allot 1514 maxburst 20 cell 8 avpkt 1000 bounded split 1:0 defmap 3f
>   tc filter add dev eth0 parent 1:0 protocol ip prio 1 u32 match ip tos 0x10 0xff classid 1:1 police rate 2Mbit burst 10K reclassify
>   tc filter add dev eth0 parent 1:0 protocol ip prio 1 u32 match ip tos 0x0c 0xff classid 1:2
>   tc filter add dev eth0 parent 1:0 protocol ip prio 2 u32 match ip tos 0x10 0xff classid 1:2
>   tc filter add dev eth0 parent 1:0 protocol ip prio 3 u32 match ip tos 0x0 0x0 classid 1:2
> 
> No changes since v1 except patch #5 to fix up struct Qdisc layout.

Looks good, series applied, thanks.
