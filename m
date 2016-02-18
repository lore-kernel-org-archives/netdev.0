From: David Miller <davem@davemloft.net>
Subject: Re: [net PATCH v3 1/1] net_sched fix: reclassification needs to
 consider ether protocol changes
Date: Thu, 18 Feb 2016 11:15:13 -0500 (EST)
Message-ID: <20160218.111513.881417469088873961.davem@davemloft.net>
References: <1455799084-6166-1-git-send-email-jhs@emojatatu.com>
	<1455799084-6166-2-git-send-email-jhs@emojatatu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, daniel@iogearbox.net,
	xiyou.wangcong@gmail.com
To: jhs@mojatatu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43469 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1946584AbcBRQPP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Feb 2016 11:15:15 -0500
In-Reply-To: <1455799084-6166-2-git-send-email-jhs@emojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jamal Hadi Salim <jhs@mojatatu.com>
Date: Thu, 18 Feb 2016 07:38:04 -0500

> From: Jamal Hadi Salim <jhs@mojatatu.com>
> 
> actions could change the etherproto in particular with ethernet
> tunnelled data. Typically such actions, after peeling the outer header,
> will ask for the packet to be  reclassified. We then need to restart
> the classification with the new proto header.
> 
> Example setup used to catch this:
> sudo tc qdisc add dev $ETH ingress
> sudo $TC filter add dev $ETH parent ffff: pref 1 protocol 802.1Q \
> u32 match u32 0 0 flowid 1:1 \
> action  vlan pop reclassify
> 
> Fixes: 3b3ae880266d ("net: sched: consolidate tc_classify{,_compat}")
> Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>

Applied and queued up for -stable, thanks Jamal.
