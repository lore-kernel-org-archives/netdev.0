From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: core: Remove redundant call to 'nf_reset' in
 'dev_forward_skb'
Date: Fri, 29 Mar 2013 15:26:06 -0400 (EDT)
Message-ID: <20130329.152606.1390301950426444505.davem@davemloft.net>
References: <1364462006-5814-1-git-send-email-shmulik.ladkani@gmail.com>
	<20130329.151120.296920819953677221.davem@davemloft.net>
	<1364584656.5113.55.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shmulik.ladkani@gmail.com, greearb@candelatech.com,
	netdev@vger.kernel.org, rgohita@gmail.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56298 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756016Ab3C2T0H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Mar 2013 15:26:07 -0400
In-Reply-To: <1364584656.5113.55.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 29 Mar 2013 12:17:36 -0700

> On Fri, 2013-03-29 at 15:11 -0400, David Miller wrote:
>> From: Shmulik Ladkani <shmulik.ladkani@gmail.com>
>> Date: Thu, 28 Mar 2013 11:13:26 +0200
>> 
>> > 'nf_reset' is called just prior calling 'netif_rx'.
>> > No need to call it twice.
>> > 
>> > Reported-by: Igor Michailov <rgohita@gmail.com>
>> > Signed-off-by: Shmulik Ladkani <shmulik.ladkani@gmail.com>
>> 
>> I do not see this happening in the:
>> 
>> 	macvlan_start_xmit()
>> 
>> 		 --> macvlan_queue_xmit()
>> 
>> code path.
>> 
>> I'm not applying this patch.  There seems to be no real agreement
>> that the caller of dev_forward_skb() takes care of the nf_reset().
>> 
>> And wouldn't it be better to consolidate the nf_reset() calls
>> into one place instead of several, increasing the audit burdon.
>> 
> 
> Hmm, I believe you misread this patch :
> 
> nf_reset() is called _twice_ in dev_forward_skb()

Aha, that makes more sense, applied.
