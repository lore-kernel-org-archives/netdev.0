From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [PATCH v3 net-next 2/3] openvswitch: Use is_skb_forwardable()
 for length check.
Date: Wed, 30 Nov 2016 14:51:59 +0100
Message-ID: <20161130145159.3cee7ba4@griffin>
References: <1480462253-114713-1-git-send-email-jarno@ovn.org>
        <1480462253-114713-2-git-send-email-jarno@ovn.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, pshelar@ovn.org, e@erig.me
To: Jarno Rajahalme <jarno@ovn.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:37948 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752845AbcK3NwD (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 30 Nov 2016 08:52:03 -0500
In-Reply-To: <1480462253-114713-2-git-send-email-jarno@ovn.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 29 Nov 2016 15:30:52 -0800, Jarno Rajahalme wrote:
> @@ -504,11 +485,20 @@ void ovs_vport_send(struct vport *vport, struct sk_buff *skb, u8 mac_proto)
>  		goto drop;
>  	}
>  
> -	if (unlikely(packet_length(skb, vport->dev) > mtu &&
> -		     !skb_is_gso(skb))) {
> -		net_warn_ratelimited("%s: dropped over-mtu packet: %d > %d\n",
> -				     vport->dev->name,
> -				     packet_length(skb, vport->dev), mtu);
> +	if (unlikely(!is_skb_forwardable(vport->dev, skb))) {

How does this work when the vlan tag is accelerated? Then we can be
over MTU, yet the check will pass.

 Jiri
