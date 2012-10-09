From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH 1/6] vxlan: minor output refactoring
Date: Tue, 09 Oct 2012 11:27:55 -0700
Message-ID: <1349807275.2386.14.camel@joe-AO722>
References: <20121009175637.048993312@vyatta.com>
	 <20121009175714.462171246@vyatta.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:39221 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752458Ab2JIS14 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Oct 2012 14:27:56 -0400
In-Reply-To: <20121009175714.462171246@vyatta.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-10-09 at 10:56 -0700, Stephen Hemminger wrote:
> +static __be32 vxlan_find_dst(struct vxlan_dev *vxlan, struct sk_buff *skb)
> +{
> +       const struct ethhdr *eth = (struct ethhdr *) skb->data;
> +       struct vxlan_fdb *f;
> +
> +       if (is_multicast_ether_addr(eth->h_dest) ||
> +           (f = vxlan_find_mac(vxlan, eth->h_dest)) == NULL)
> +               return vxlan->gaddr;
> +       else
> +               return f->remote_ip;
> +}

Bikeshedding:

This might be simpler to read with a few more lines like:

static __be32 vxlan_find_dst(struct vxlan_dev *vxlan, struct sk_buff *skb)
{
	const struct ethhdr *eth = (const struct ethhdr *)skb->data;
	struct vxlan_fdb *f;

	if (is_multicast_ether_addr(eth->h_dest))
		return vxlan->gaddr;

	f = vxlan_find_mac(vxlan, eth->h_dest);
	if (!f)
		return vxlan->gaddr;

	return f->remote_ip;
}
