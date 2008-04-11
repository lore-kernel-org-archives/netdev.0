From: Patrick McHardy <kaber@trash.net>
Subject: Re: Re-queueing of skb in vlan_skb_recv
Date: Fri, 11 Apr 2008 14:46:35 +0200
Message-ID: <47FF5DAB.1060906@trash.net>
References: <8A9D56C5E50F774BABE033F1710B357601084C42@BBY1EXM11.pmc_nt.nt.pmc-sierra.bc.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-net@vger.kernel.org,
	Linux Netdev List <netdev@vger.kernel.org>
To: Brian Oostenbrink <Brian_Oostenbrink@pmc-sierra.com>
Return-path: <linux-net-owner@vger.kernel.org>
In-Reply-To: <8A9D56C5E50F774BABE033F1710B357601084C42@BBY1EXM11.pmc_nt.nt.pmc-sierra.bc.ca>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Brian Oostenbrink wrote:
> In vlan_skb_recv, packets are generally stripped of their vlan header,
> and then re-queued via netif_rx().  Is there a reason for re-queuing
> these instead of calling netif_receive_skb() directly?  On our system
> (an embedded linux router), this re-queuing has a significant
> performance penalty.

Its done to save stack space. There's currently a discussion
about making loopback use netif_receive_skb in case enough
stack is still available. Once that patch gets merged I'll
change VLAN in a similar way.

