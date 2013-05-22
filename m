From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v3] net: Loosen constraints for recalculating
 checksum in skb_segment()
Date: Wed, 22 May 2013 15:06:36 -0700 (PDT)
Message-ID: <20130522.150636.1572124345721031295.davem@davemloft.net>
References: <1369014409-14629-1-git-send-email-horms@verge.net.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dev@openvswitch.org, netdev@vger.kernel.org, jesse@nicira.com,
	pshelar@nicira.com, jarno.rajahalme@nsn.com,
	eric.dumazet@gmail.com, maze@google.com
To: horms@verge.net.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45187 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756649Ab3EVWGi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 May 2013 18:06:38 -0400
In-Reply-To: <1369014409-14629-1-git-send-email-horms@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Simon Horman <horms@verge.net.au>
Date: Mon, 20 May 2013 10:46:49 +0900

> This is a generic solution to resolve a specific problem that I have observed.
> 
> If the encapsulation of an skb changes then ability to offload checksums
> may also change. In particular it may be necessary to perform checksumming
> in software.
> 
> An example of such a case is where a non-GRE packet is received but
> is to be encapsulated and transmitted as GRE.
> 
> Another example relates to my proposed support for for packets
> that are non-MPLS when received but MPLS when transmitted.
> 
> The cost of this change is that the value of the csum variable may be
> checked when it previously was not. In the case where the csum variable is
> true this is pure overhead. In the case where the csum variable is false it
> leads to software checksumming, which I believe also leads to correct
> checksums in transmitted packets for the cases described above.
> 
> Further analysis:
> 
> This patch relies on the return value of can_checksum_protocol()
> being correct and in turn the return value of skb_network_protocol(),
> used to provide the protocol parameter of can_checksum_protocol(),
> being correct. It also relies on the features passed to skb_segment()
> and in turn to can_checksum_protocol() being correct.
> 
> I believe that this problem has not been observed for VLANs because it
> appears that almost all drivers, the exception being xgbe, set
> vlan_features such that that the checksum offload support for VLAN packets
> is greater than or equal to that of non-VLAN packets.
> 
> I wonder if the code in xgbe may be an oversight and the hardware does
> support checksumming of VLAN packets.  If so it may be worth updating the
> vlan_features of the driver as this patch will force such checksums to be
> performed in software rather than hardware.
> 
> Signed-off-by: Simon Horman <horms@verge.net.au>

Applied, thanks Simon.
