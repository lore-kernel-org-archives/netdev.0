From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bnx2: Use dev_kfree_skb_any() in bnx2_tx_int()
Date: Thu, 31 Oct 2013 00:26:02 -0400 (EDT)
Message-ID: <20131031.002602.2030884257299947291.davem@davemloft.net>
References: <CAM_iQpV6ufX5-OOrNQtsXH0_9itjU-FriOoutyKfDEWdg-irQw@mail.gmail.com>
	<20131030.173200.2256841895208134119.davem@davemloft.net>
	<CAM_iQpWAbSWVeAMwhQADTwO_RdYUXfog-wG9gs4+Zek0g_5Oyg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tdmackey@booleanhaiku.com, mchan@broadcom.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: xiyou.wangcong@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAM_iQpWAbSWVeAMwhQADTwO_RdYUXfog-wG9gs4+Zek0g_5Oyg@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Cong Wang <xiyou.wangcong@gmail.com>
Date: Wed, 30 Oct 2013 15:01:12 -0700

> On Wed, Oct 30, 2013 at 2:32 PM, David Miller <davem@davemloft.net> wrote:
>>
>> Explain to me then why other ethernet drivers implemented identically,
>> such as tg3, can use plain dev_kfree_skb() just fine?
> 
> I don't think they are fine, I just don't see bug reports
> for them. At very least, I saw a same bug report for be2net too.
> 
> To reproduce this bug, we need to find some one calling printk()
> within IRQ handler, which seems rare? It seems there are few
> people using hpsa driver together with netconsole.

We've had this conversation before I believe, and I absolutely do not
want to have to add IRQ safety to every ->poll() implementation.

We have to provide a softint compatible environment for this callback
to run in else everything is completely broken.

All these drivers can safely assume softirq safe locking is
sufficient, you're suggesting we need to take this hardirq safety and
I'm really not willing to allow things to go that far.  A lot of
effort has been expended precisely to avoid that kind of overhead and
cost.
