From: Ben Greear <greearb@candelatech.com>
Subject: Re: RFC - should network devices trim frames > soft mtu
Date: Wed, 31 Aug 2011 15:26:14 -0700
Message-ID: <4E5EB506.6000409@candelatech.com>
References: <20110831151823.23cfb7bc@nehalam.ftrdhcpuser.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Michael Chan <mchan@broadcom.com>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:44794 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756941Ab1HaW0R (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Aug 2011 18:26:17 -0400
In-Reply-To: <20110831151823.23cfb7bc@nehalam.ftrdhcpuser.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/31/2011 03:18 PM, Stephen Hemminger wrote:
> I noticed the following in the bnx2 driver.
>
>
> static int
> bnx2_rx_int(struct bnx2 *bp, struct bnx2_napi *bnapi, int budget)
> {
> ...
> 		skb->protocol = eth_type_trans(skb, bp->dev);
>
> 		if ((len>  (bp->dev->mtu + ETH_HLEN))&&
> 			(ntohs(skb->protocol) != 0x8100)) {
>
> 			dev_kfree_skb(skb);
> 			goto next_rx;
>
> 		}
>
> This means that for non-VLAN tagged frames, the device drops received
> packets if the length is greater than the MTU.  I don't see that in
> other devices. What is the correct method? IMHO the bnx2 driver is
> wrong here and if the policy is desired it should be enforced at
> the next level (netif_receive_skb).  Hardcoding a protocol value is
> kind of a giveaway that something is fishy.

Maybe that lets them use some kind of offload?

Either way, seems the pkt should be allowed to come up the
stack if the NIC can receive it and it's not otherwise funky.

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
