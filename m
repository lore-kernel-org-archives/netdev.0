From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/2] Fix issues with vlans without REORDER_HEADER
Date: Tue, 17 Nov 2015 14:39:06 -0500 (EST)
Message-ID: <20151117.143906.2184213061071335097.davem@davemloft.net>
References: <1447706625-25979-1-git-send-email-vyasevic@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, phil@nwl.cc, kaber@trash.net,
	vyasevic@redhat.com
To: vyasevich@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58142 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754700AbbKQTjI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Nov 2015 14:39:08 -0500
In-Reply-To: <1447706625-25979-1-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vladislav Yasevich <vyasevich@gmail.com>
Date: Mon, 16 Nov 2015 15:43:43 -0500

> A while ago Phil Sutter brought up an issue with vlans without
> REORDER_HEADER and bridges.  The problem was that if a vlan
> without REORDER_HEADER was a port in the bridge, the bridge ended
> up forwarding corrupted packets that still contained the vlan header.
> The same issue exists for bridge mode macvlan/macvtap devices.
> 
> An additional issue with vlans without REORDER_HEADER is that stacking
> them also doesn't work.  The reason here is that skb_reorder_vlan_header()
> function assumes that it on ETH_HLEN bytes deep into the packet.  That
> is not the case, when you a vlan without REORRDER_HEADER flag set.
> 
> This series attempts to correct these 2 issues.
> 
> 1) To solve the stacked vlans problem, the patch simply use
> skb->mac_len as an offset to start copying mac addresses that
> is part of header reordering.
> 
> 2) To fix the issue with bridge/macvlan/macvtap, the second patch
> simply doesn't write the vlan header back to the packet if the
> vlan device is either a bridge or a macvlan port.  This ends up
> being the simplest and least performance intrussive solution.
> 
> I've considered extending patch 2 to all stacked devices (essentially
> checked for the presense of rx_handler), but that feels like a broader
> restriction and _may_ break existing uses.  

Series applied, thanks for working on this Vlad.
