From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH v4 net-next] MPLS: Use mpls_features to activate software
 MPLS GSO segmentation
Date: Mon, 2 Jun 2014 17:21:45 +0100
Message-ID: <20140602162145.GA3836@casper.infradead.org>
References: <1401684215-14713-1-git-send-email-horms@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Jesse Gross <jesse@nicira.com>,
	YAMAMOTO Takashi <yamamoto@valinux.co.jp>, dev@openvswitch.org
To: Simon Horman <horms@verge.net.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:37140 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752903AbaFBQVt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Jun 2014 12:21:49 -0400
Content-Disposition: inline
In-Reply-To: <1401684215-14713-1-git-send-email-horms@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/02/14 at 01:43pm, Simon Horman wrote:
> +#ifdef CONFIG_NET_MPLS_GSO
> +static netdev_features_t net_mpls_features(struct sk_buff *skb,
> +					   struct net_device *dev,
> +					   netdev_features_t features)
> +{
> +	/* There is no support for MPLS LRO. So the only way that
> +	 * an MPLS skb could require GSO segmentation is if it
> +	 * was received as a non-MPLS skb and then became an MPLS skb.
> +	 * This may be effected by Open vSwitch in which case the
> +	 * mac_len will non-zero and not equal to skb_network_offset
> +	 * as the former indicates the end of L2 while the latter indicates
> +	 * the beginning of L3 and there is a gap between them occupied
> +	 * by the MPLS label stack.
> +	 *
> +	 * Thus it is possible to avoid traversing any VLAN tags that are
> +	 * present to determine if the ethtype is MPLS. Instead the
> +	 * inequality of mac_len and skb_network_offset are used to
> +	 * determine if a packet is MPLS for the purpose of determining
> +	 * offload features.
> +	 */
> +	if (skb->mac_len && skb->mac_len != skb_network_offset(skb))
> +		features &= dev->mpls_features;
> +	return features;
> +}

Could you elaborate a bit on the safety of this? What about
GRE GSO which sets mac_len to the inner network offset?
