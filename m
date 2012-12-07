From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH] af_packet: don't to defrag shared skb
Date: Fri, 07 Dec 2012 14:10:55 -0500 (EST)
Message-ID: <20121207.141055.2052060513814647508.davem@davemloft.net>
References: <1354906561-4695-1-git-send-email-eric@regit.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric@regit.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57642 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756699Ab2LGTK4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Dec 2012 14:10:56 -0500
In-Reply-To: <1354906561-4695-1-git-send-email-eric@regit.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Leblond <eric@regit.org>
Date: Fri,  7 Dec 2012 19:56:01 +0100

> This patch is adding a check on skb before trying to defrag the
> packet for the hash computation in fanout mode. The goal of this
> patch is to avoid an kernel crash in pskb_expand_head.
> It appears that under some specific condition there is a shared
> skb reaching the defrag code and this lead to a crash due to the
> following code:
> 
> 	if (skb_shared(skb))
> 		BUG();
> 
> I've observed this crash under the following condition:
>  1. a program is listening to an wifi interface (let say wlan0)
>  2. it is using fanout capture in flow load balancing mode
>  3. defrag option is on on the fanout socket
>  4. the interface disconnect (radio down for example)
>  5. the interface reconnect (radio switched up)
>  6. once reconnected a single packet is seen with skb->users=2
>  7. the kernel crash in pskb_expand_head at skbuff.c:1035
 ...
> Signed-off-by: Eric Leblond <eric@regit.org>

Thanks Eric.  I'll try to figure out if we should instead
change the wireless code to avoid sending shared SKBs into
the input path like that.
