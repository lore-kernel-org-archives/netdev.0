From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2.6.35-rc1] net-next: vmxnet3 fixes [1/5] Spare skb to
 avoid starvation
Date: Thu, 15 Jul 2010 18:39:13 -0700 (PDT)
Message-ID: <20100715.183913.71134002.davem@davemloft.net>
References: <alpine.LRH.2.00.1007070214400.6105@localhost.localdomain>
	<alpine.LRH.2.00.1007131743520.32055@localhost.localdomain>
	<alpine.LRH.2.00.1007151656140.10176@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, pv-drivers@vmware.com,
	linux-kernel@vger.kernel.org
To: sbhatewara@vmware.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.LRH.2.00.1007151656140.10176@localhost.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Shreyas Bhatewara <sbhatewara@vmware.com>
Date: Thu, 15 Jul 2010 18:19:39 -0700 (PDT)

> 
> Reposting this patch with struct vmxnet3_cmd_ring *ring made const 
> according to Stephen's feedback.

Please address my feedback, which is that this is not the way to
handle this problem.

You can prevent all forms of starvation, without hacky spare-skbs or
things like that, by trying to allocate the replacement SKB _before_
sending the packet up to the stack.

If the replacement SKB allocation fails, you do not give the packet to
the network stack.  Instead, you give it back to the card's RX ring.

See drivers/net/tg3.c, drivers/net/niu.c, etc. for examples of this.
