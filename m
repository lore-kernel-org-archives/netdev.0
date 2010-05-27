From: John Fastabend <john.r.fastabend@intel.com>
Subject: Re: [PATCH 3/3] net: deliver skbs on inactive slaves to exact matches
Date: Wed, 26 May 2010 21:52:58 -0700
Message-ID: <4BFDFAAA.8070701@intel.com>
References: <20100513073106.3528.45412.stgit@jf-dev2-dcblab> <20100513073117.3528.33132.stgit@jf-dev2-dcblab>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
To: "andy@greyhouse.net" <andy@greyhouse.net>,
	"fubar@us.ibm.com" <fubar@us.ibm.com>,
	"nhorman@tuxdriver.com" <nhorman@tuxdriver.com>,
	"bonding-devel@lists.sourceforge.net"
	<bonding-dev
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:15162 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932900Ab0E0Ew7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 May 2010 00:52:59 -0400
In-Reply-To: <20100513073117.3528.33132.stgit@jf-dev2-dcblab>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fastabend, John R wrote:
> Currently, the accelerated receive path for VLAN's will
> drop packets if the real device is an inactive slave and
> is not one of the special pkts tested for in
> skb_bond_should_drop().  This behavior is different then
> the non-accelerated path and for pkts over a bonded vlan.
> 
> For example,
> 
> vlanx -> bond0 -> ethx
> 
> will be dropped in the vlan path and not delivered to any
> packet handlers at all.  However,
> 
> bond0 -> vlanx -> ethx
> 
> and
> 
> bond0 -> ethx
> 
> will be delivered to handlers that match the exact dev,
> because the VLAN path checks the real_dev which is not a
> slave and netif_recv_skb() doesn't drop frames but only
> delivers them to exact matches.
> 
> This patch adds a sk_buff flag which is used for tagging
> skbs that would previously been dropped and allows the
> skb to continue to skb_netif_recv().  Here we add
> logic to check for the bond_should_drop flag and if it
> is set only deliver to handlers that match exactly.  This
> makes both paths above consistent and gives pkt handlers
> a way to identify skbs that come from inactive slaves.
> Without this patch in some configurations skbs will be
> delivered to handlers with exact matches and in others
> be dropped out right in the vlan path.
> 
> I have tested the following 4 configurations in failover modes
> and load balancing modes.
> 
> # bond0 -> ethx
> 
> # vlanx -> bond0 -> ethx
> 
> # bond0 -> vlanx -> ethx
> 
> # bond0 -> ethx
>             |
>   vlanx -> --
> 
> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
> ---
> 

Jay,

I know you were looking over this series at one point.  Did you have any 
comments?  Sorry for the ping just wanted to keep this on my radar.

Thanks,
John
