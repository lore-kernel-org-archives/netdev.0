From: Amir Vadai <amirv@mellanox.com>
Subject: Re: [PATCH net V1 1/3] net/mlx4_en: Don't use irq_affinity_notifier
 to track changes in IRQ affinity map
Date: Tue, 1 Jul 2014 12:14:29 +0300
Message-ID: <53B27BF5.6080608@mellanox.com>
References: <1404032097-5132-2-git-send-email-amirv@mellanox.com>	<1404110511.15139.44.camel@edumazet-glaptop2.roam.corp.google.com>	<53B1210E.6040409@gmail.com> <20140630.203308.1311350484055713992.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <eric.dumazet@gmail.com>, <netdev@vger.kernel.org>,
	<ogerlitz@mellanox.com>, <yevgenyp@mellanox.com>,
	<tglx@linutronix.de>, <ben@decadent.org.uk>, <amira@mellanox.com>,
	<yuvala@mellanox.com>
To: David Miller <davem@davemloft.net>, <amirv.mellanox@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-am1lp0015.outbound.protection.outlook.com ([213.199.154.15]:40669
	"EHLO emea01-am1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751961AbaGAJ3j (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Jul 2014 05:29:39 -0400
In-Reply-To: <20140630.203308.1311350484055713992.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/01/2014 06:33 AM, David Miller wrote:
> From: Amir Vadai <amirv.mellanox@gmail.com>
> Date: Mon, 30 Jun 2014 11:34:22 +0300
>
>> On 6/30/2014 9:41 AM, Eric Dumazet wrote:
>>> You might want to drain whole queue instead of limiting to a 'budget',
>>> otherwise, a cpu might be stuck servicing (soft)irq for the TX
>>> completion, even if irq affinities say otherwise.
>>>
>>
>> TX completions are very quick compared to the skb preparation and
>> sending. Which is not the case for RX completions. Because of that, it
>> is very easy to reproduce the problem in RX flows, but we never had any
>> report of that problem in the TX flow.
>> I prefer not to spend time on the TX, since we plan to send a patch soon
>> to use the same NAPI for both TX and RX.
>
> It is always advised to completely ignore the budget for TX work, this is
> what we tell every driver author when discussion NAPI implementations.
>
> Please make your driver conform to this, thanks.
>

Ok.

Please continue the process on this V1 of the patchset. The fix to TX 
poll is not related to this patch - this patch is fixing a regression 
that broke aRFS in mlx4_en.

I will send a separate fix to purge all packets on TX work later on this 
week.

Thanks,
Amir
