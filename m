From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] xen-netback: Turn off the carrier if the guest is not
 able to receive
Date: Thu, 31 Jul 2014 21:53:44 -0700 (PDT)
Message-ID: <20140731.215344.1226846407150746376.davem@davemloft.net>
References: <1406749849-4356-1-git-send-email-zoltan.kiss@citrix.com>
	<1406749849-4356-2-git-send-email-zoltan.kiss@citrix.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: wei.liu2@citrix.com, Ian.Campbell@citrix.com,
	david.vrabel@citrix.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, xen-devel@lists.xenproject.org
To: zoltan.kiss@citrix.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1406749849-4356-2-git-send-email-zoltan.kiss@citrix.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Zoltan Kiss <zoltan.kiss@citrix.com>
Date: Wed, 30 Jul 2014 20:50:49 +0100

> Currently when the guest is not able to receive more packets, qdisc layer starts
> a timer, and when it goes off, qdisc is started again to deliver a packet again.
> This is a very slow way to drain the queues, consumes unnecessary resources and
> slows down other guests shutdown.
> This patch change the behaviour by turning the carrier off when that timer
> fires, so all the packets are freed up which were stucked waiting for that vif.
> Instead of the rx_queue_purge bool it uses the VIF_STATUS_RX_PURGE_EVENT bit to
> signal the thread that either the timout happened or an RX interrupt arrived, so
> the thread can check what it should do. It also disables NAPI, so the guest
> can't transmit, but leaves the interrupts on, so it can resurrect.
> 
> Signed-off-by: Zoltan Kiss <zoltan.kiss@citrix.com>
> Signed-off-by: David Vrabel <david.vrabel@citrix.com>

When posting a multi-part patch set, number your patches and have a header
"[PATCH 0/N] " posting which describes at a high level what the patch
series is doing, and why.

> +				for (i = 0; i < num_queues; ++i) {

Please use the more canonical "i++" increment.

Thanks.
