From: Amir Vadai <amirv.mellanox@gmail.com>
Subject: Re: [PATCH net V1 1/3] net/mlx4_en: Don't use irq_affinity_notifier
 to track changes in IRQ affinity map
Date: Mon, 30 Jun 2014 13:43:35 +0300
Message-ID: <53B13F57.5060901@gmail.com>
References: <1404032097-5132-1-git-send-email-amirv@mellanox.com>		 <1404032097-5132-2-git-send-email-amirv@mellanox.com>	 <1404110511.15139.44.camel@edumazet-glaptop2.roam.corp.google.com>	 <53B1210E.6040409@gmail.com> <1404119512.15139.70.camel@edumazet-glaptop2.roam.corp.google.com>
Reply-To: amirv@mellanox.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	Ben Hutchings <ben@decadent.org.uk>, amira@mellanox.com,
	Yuval Atias <yuvala@mellanox.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f172.google.com ([209.85.212.172]:45652 "EHLO
	mail-wi0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752581AbaF3Knj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Jun 2014 06:43:39 -0400
Received: by mail-wi0-f172.google.com with SMTP id hi2so5807627wib.5
        for <netdev@vger.kernel.org>; Mon, 30 Jun 2014 03:43:38 -0700 (PDT)
In-Reply-To: <1404119512.15139.70.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 6/30/2014 12:11 PM, Eric Dumazet wrote:
> On Mon, 2014-06-30 at 11:34 +0300, Amir Vadai wrote:
> 
>> TX completions are very quick compared to the skb preparation and
>> sending. Which is not the case for RX completions. Because of that, it
>> is very easy to reproduce the problem in RX flows, but we never had any
>> report of that problem in the TX flow.
> 
> This is because reporters probably use same number of RX and TX queues.
> 
> With TCP Small queues, TX completions are not always quick, if thousands
> of flows are active.
> 
> Some people hit the locked cpu when say one cpu has to drain 8 TX
> queues, because 7 other cpus can continuously feed more packets 
> 
>> I prefer not to spend time on the TX, since we plan to send a patch soon
>> to use the same NAPI for both TX and RX.
> 
> Thanks, this sounds great.
> 
> 

Ok, so unless anyone objects, the plan is to continue with this patch
(RX only). If the unified NAPI patch will be delayed I will send the TX
fix too.

Amir
