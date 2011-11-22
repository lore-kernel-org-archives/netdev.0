From: David Miller <davem@davemloft.net>
Subject: Re: softirq oops from b44_poll
Date: Tue, 22 Nov 2011 15:54:26 -0500 (EST)
Message-ID: <20111122.155426.1153643155035648664.davem@davemloft.net>
References: <CAJfGthSxanFbL2vKCpOQbP9K5oNAxeaYt7OMdmdoCb4eLQ_Fww@mail.gmail.com>
	<1321917453.10276.3.camel@pjaxe>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: lkml@hover.be, linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: peter.p.waskiewicz.jr@intel.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1321917453.10276.3.camel@pjaxe>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Date: Mon, 21 Nov 2011 15:17:33 -0800

> I suspect the "right" way to fix this is to call dev_kfree_skb_any(skb);
> instead, since that will handle the in-interrupt case if that's where
> we're stuck.

Caller is always b44_poll(), and that caller always does spin_lock_irqsave().

Adding the extra tests implied by dev_kfree_skb_any() therefore doesn't
make any sense, as it will always evaluate to dev_kfree_skb_irq().
