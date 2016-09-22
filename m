From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 net-next 1/2] net: skbuff: Remove errornous length
 validation in skb_vlan_pop()
Date: Thu, 22 Sep 2016 01:36:29 -0400 (EDT)
Message-ID: <20160922.013629.367187899272461834.davem@davemloft.net>
References: <1474364917-31710-1-git-send-email-shmulik.ladkani@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jiri@mellanox.com, daniel@iogearbox.net, pshelar@ovn.org,
        eric.dumazet@gmail.com, netdev@vger.kernel.org,
        shmulik.ladkani@gmail.com
To: shmulik.ladkani@ravellosystems.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:54648 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753706AbcIVFgd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 22 Sep 2016 01:36:33 -0400
In-Reply-To: <1474364917-31710-1-git-send-email-shmulik.ladkani@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shmulik Ladkani <shmulik.ladkani@ravellosystems.com>
Date: Tue, 20 Sep 2016 12:48:36 +0300

> In 93515d53b1
>   "net: move vlan pop/push functions into common code"
> skb_vlan_pop was moved from its private location in openvswitch to
> skbuff common code.
> 
> In case skb has non hw-accel vlan tag, the original 'pop_vlan()' assured
> that skb->len is sufficient (if skb->len < VLAN_ETH_HLEN then pop was
> considered a no-op).
> 
> This validation was moved as is into the new common 'skb_vlan_pop'.
> 
> Alas, in its original location (openvswitch), there was a guarantee that
> 'data' points to the mac_header, therefore the 'skb->len < VLAN_ETH_HLEN'
> condition made sense.
> However there's no such guarantee in the generic 'skb_vlan_pop'.
> 
> For short packets received in rx path going through 'skb_vlan_pop',
> this causes 'skb_vlan_pop' to fail pop-ing a valid vlan hdr (in the non
> hw-accel case) or to fail moving next tag into hw-accel tag.
> 
> Remove the 'skb->len < VLAN_ETH_HLEN' condition entirely:
> It is superfluous since inner '__skb_vlan_pop' already verifies there
> are VLAN_ETH_HLEN writable bytes at the mac_header.
> 
> Note this presents a slight change to skb_vlan_pop() users:
> In case total length is smaller than VLAN_ETH_HLEN, skb_vlan_pop() now
> returns an error, as opposed to previous "no-op" behavior.
> Existing callers (e.g. tc act vlan, ovs) usually drop the packet if
> 'skb_vlan_pop' fails.
> 
> Fixes: 93515d53b1 ("net: move vlan pop/push functions into common code")
> Signed-off-by: Shmulik Ladkani <shmulik.ladkani@gmail.com>

Applied.
