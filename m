From: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
Subject: Re: [PATCH net-next 1/4] flow_dissector: Get vlan info from
 skb->vlan_tci instead of skb->data
Date: Fri, 12 Aug 2016 15:36:49 +0900
Message-ID: <e16e8104-c010-e812-74c8-d28960e23643@lab.ntt.co.jp>
References: <1470835943-9042-1-git-send-email-hadarh@mellanox.com>
 <1470835943-9042-2-git-send-email-hadarh@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Jiri Pirko <jiri@mellanox.com>,
	Tom Herbert <tom@herbertland.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>
To: Hadar Hen Zion <hadarh@mellanox.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tama50.ecl.ntt.co.jp ([129.60.39.147]:43407 "EHLO
	tama50.ecl.ntt.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750807AbcHLGhd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Aug 2016 02:37:33 -0400
In-Reply-To: <1470835943-9042-2-git-send-email-hadarh@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2016/08/10 22:32, Hadar Hen Zion wrote:
> Early in the datapath skb_vlan_untag function is called, stripped
> the vlan from the skb and set skb->vlan_tci and skb->vlan_proto fields.
> 
> The current dissection doesn't handle vlan packets correctly.  Vlan
> doesn't exist in skb->data anymore when applying flow dissection on the
> skb, fix that.

RPS (and flow-dissector called in RPS) is performed before vlan-strip in
__netif_receive_skb_core().
Also, in cases skb is tagged with multiple vlan headers (typical when
using 802.1ad), the second level vlan tag is in skb->data.
So I think you should handle both of skb->vlan_tci and skb->data cases.

Thanks,
Toshiaki Makita
