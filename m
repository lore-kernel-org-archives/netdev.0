From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH V2 net-next] net: hns: Fix to conditionally convey RX
 checksum flag to stack
Date: Sat, 03 Dec 2016 15:09:05 -0500 (EST)
Message-ID: <20161203.150905.739546865468666597.davem@davemloft.net>
References: <20161129130945.919372-1-salil.mehta@huawei.com>
        <20161130.142539.1927956259851457047.davem@davemloft.net>
        <F4CC6FACFEB3C54C9141D49AD221F7F91A7D4439@lhreml503-mbx>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yisen.zhuang@huawei.com, mehta.salil.lnk@gmail.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        linuxarm@huawei.com
To: salil.mehta@huawei.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <F4CC6FACFEB3C54C9141D49AD221F7F91A7D4439@lhreml503-mbx>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Salil Mehta <salil.mehta@huawei.com>
Date: Thu, 1 Dec 2016 12:09:22 +0000

> But maybe now since we don't have any method to de-multiplex the kind of
> checksum error (cannot depend upon register) we can have below code
> re-arrangement:
> 
> hns_nic_rx_checksum() {
>       /* check supported L3 protocol */
> 	if (l3 != IPV4 && l3 != IPV6)
> 		return;
>       /* check if L3 protocols error */
>       if (l3e)
> 	 	return;
> 
>       /* check if the packets are fragmented */
> 	If (l3frags)
> 		Return;
> 
>       /* check supported L4 protocol */
>  	if (l4 != UDP && l4 != TCP && l4 != SCTP)
>  		return;
>       /* check if any L4 protocol error */
>       if (l3e)
> 	 	return;
> 
>       /* packet with valid checksum - covey to stack */
>       skb->ip_summed = CHECKSUM_UNNECESSARY
> }

This looks a lot cleaner and easier to understand.
