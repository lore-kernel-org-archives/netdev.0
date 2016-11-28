From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [PATCH net-next 2/2] openvswitch: Fix skb->protocol for vlan
 frames.
Date: Mon, 28 Nov 2016 23:42:46 +0100
Message-ID: <20161128234246.1a886246@griffin>
References: <1479874174-75329-1-git-send-email-jarno@ovn.org>
        <1479874174-75329-2-git-send-email-jarno@ovn.org>
        <20161124171046.7eb0e287@griffin>
        <76814927-D373-4C3A-BC85-5771304235A7@ovn.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8BIT
Cc: netdev@vger.kernel.org
To: Jarno Rajahalme <jarno@ovn.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:34752 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755071AbcK1Wmt (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 28 Nov 2016 17:42:49 -0500
In-Reply-To: <76814927-D373-4C3A-BC85-5771304235A7@ovn.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 28 Nov 2016 14:29:39 -0800, Jarno Rajahalme wrote:
> I’m not sure what you suggest here. Obviously the kernel ABI can not
> be changed as existing userspace code expects upcalled packets to be
> non-accelerated. Also, if userspace pushes vlan headers, the packet
> will actually have them.

The user space API needs to be preserved, of course. I'm talking about
what happens internally in the kernel.

See this patchset: https://www.spinics.net/lists/netdev/msg398827.html

> Would this incremental fix this:
> 
> diff --git a/net/openvswitch/flow.c b/net/openvswitch/flow.c
> index 9be9fda..37f1bb9 100644
> --- a/net/openvswitch/flow.c
> +++ b/net/openvswitch/flow.c
> @@ -354,6 +354,8 @@ static int parse_vlan(struct sk_buff *skb, struct
> sw_flow_key *key) res = parse_vlan_tag(skb, &key->eth.vlan);
>  		if (res <= 0)
>  			return res;
> +		if (skb->protocol == htons(ETH_P_TEB))
> +			skb->protocol = key->eth.vlan.tpid;
>  	}
>  
>  	/* Parse inner vlan tag. */

I'll look at this tomorrow. But it seems we're adding more and more
hacks instead of cleaning up the vlan handling.

 Jiri
