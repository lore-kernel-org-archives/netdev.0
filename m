From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net v6 4/4] tg3: Fix tx_pending checks for tg3_tso_bug
Date: Tue, 30 Sep 2014 21:24:49 -0700
Message-ID: <1412137489.16704.26.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1409960135.18724.33.camel@prashant>
		<1409961810.26422.149.camel@edumazet-glaptop2.roam.corp.google.com>
		<20140905.171306.1460013939580748402.davem@davemloft.net>
	 <20140905.213902.1124686922505260665.davem@davemloft.net>
	 <542B71B1.4020103@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, bpoirier@suse.de,
	mchan@broadcom.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Prashant <prashant@broadcom.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <542B71B1.4020103@broadcom.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2014-09-30 at 20:14 -0700, Prashant wrote:

> Sorry about the late reply, out of all the HW bug conditions checked in 
> tg3_tx_frag_set() the most frequently hit condition is the short 8 byte 
> dma bug, where the chip cannot handle TX descriptors whose data buffer 
> is 8 bytes or less. Most of the LSO skb's given to the driver has their 
> fragments filled upto PAGE_SIZE (expect the last fragment depending on 
> skb->len). And if such a LSO skb's last fragment meets the 8 bytes HW 
> bug condition the above routine will not help workaround this particular 
> case.

Thats pretty easy to work around.

Say rebuilt skb has N frags (N > 1 given your description)

They are numbered 0, ... N-2, N-1

Instead of filling N-2 completely, fill it to PAGE_SIZE-8, so that last
frag has at least 8 bytes in it.

Also take a look at commit 2e4e44107176d552f8bb1bb76053e850e3809841
("net: add alloc_skb_with_frags() helper")
