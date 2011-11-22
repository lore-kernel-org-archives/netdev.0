From: Xander Hover <lkml@hover.be>
Subject: Re: softirq oops from b44_poll
Date: Wed, 23 Nov 2011 00:16:48 +0100
Message-ID: <CAJfGthTb8PJXNq3gP_NPxTLQQNuVM600oF5Qx7cW-ykGe4n9gQ@mail.gmail.com>
References: <CAJfGthSxanFbL2vKCpOQbP9K5oNAxeaYt7OMdmdoCb4eLQ_Fww@mail.gmail.com>
	<1321917453.10276.3.camel@pjaxe>
	<20111122.155426.1153643155035648664.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: peter.p.waskiewicz.jr@intel.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20111122.155426.1153643155035648664.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Indeed will the in_irq() test will force dev_kfree_skb_any() to call
dev_kfree_skb_irq().
The kernel warning before this patch was applied, was also trigged by
a WARN_ON_ONCE(in_irq()).
I think David is right on this one.


On Tue, Nov 22, 2011 at 9:54 PM, David Miller <davem@davemloft.net> wrote:
> From: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
> Date: Mon, 21 Nov 2011 15:17:33 -0800
>
>> I suspect the "right" way to fix this is to call dev_kfree_skb_any(skb);
>> instead, since that will handle the in-interrupt case if that's where
>> we're stuck.
>
> Caller is always b44_poll(), and that caller always does spin_lock_irqsave().
>
> Adding the extra tests implied by dev_kfree_skb_any() therefore doesn't
> make any sense, as it will always evaluate to dev_kfree_skb_irq().
>
