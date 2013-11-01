From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bnx2: Use dev_kfree_skb_any() in bnx2_tx_int()
Date: Fri, 01 Nov 2013 18:01:47 -0400 (EDT)
Message-ID: <20131101.180147.629210014672277622.davem@davemloft.net>
References: <CAM_iQpWAbSWVeAMwhQADTwO_RdYUXfog-wG9gs4+Zek0g_5Oyg@mail.gmail.com>
	<20131031.002602.2030884257299947291.davem@davemloft.net>
	<CAM_iQpXPrEj619=PRaKN4PxgOoEB96U0mLFS65AzXOezSWvhxQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: mchan@broadcom.com, tdmackey@booleanhaiku.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: xiyou.wangcong@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAM_iQpXPrEj619=PRaKN4PxgOoEB96U0mLFS65AzXOezSWvhxQ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Cong Wang <xiyou.wangcong@gmail.com>
Date: Thu, 31 Oct 2013 21:19:16 -0700

> 2013年10月30日 下午9:26于 "David Miller" <davem@davemloft.net>写道：
>>
>> We have to provide a softint compatible environment for this callback
>> to run in else everything is completely broken.
>>
>> All these drivers can safely assume softirq safe locking is
>> sufficient, you're suggesting we need to take this hardirq safety and
>> I'm really not willing to allow things to go that far.  A lot of
>> effort has been expended precisely to avoid that kind of overhead and
>> cost.
> 
> Alright, I am thinking to move netpoll_poll_dev() to a delayed work.
 
What if the printk is outputting a message that will help us discover
that work queues are deadlocked?

You can't delay the message, because every layer of indirection you
add increases the possibility that the message it never seen.  You
have to do it synchronously.
