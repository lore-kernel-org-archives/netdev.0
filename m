From: Edward Cree <ecree@solarflare.com>
Subject: Re: [RFC PATCH net-next 7/8] net: ipv4: listified version of ip_rcv
Date: Thu, 21 Apr 2016 18:24:49 +0100
Message-ID: <57190CE1.3050302@solarflare.com>
References: <5716338E.4050003@solarflare.com>
 <5716347D.3030808@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Jesper Dangaard Brouer <brouer@redhat.com>,
	<linux-net-drivers@solarflare.com>
To: <netdev@vger.kernel.org>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo04.seg.att.com ([209.65.160.86]:49778 "EHLO
	nbfkord-smmo04.seg.att.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751340AbcDURZF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Apr 2016 13:25:05 -0400
In-Reply-To: <5716347D.3030808@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 19/04/16 14:37, Edward Cree wrote:
> Also involved adding a way to run a netfilter hook over a list of packets.
Turns out, this breaks the build if netfilter is *disabled*, because I forgot to
add a stub in that case.  Next version of patch (if there is one) will have the
following under #ifndef CONFIG_NETFILTER:

static inline void
NF_HOOK_LIST(uint8_t pf, unsigned int hook, struct net *net, struct sock *sk,
	     struct sk_buff_head *list, struct sk_buff_head *sublist,
	     struct net_device *in, struct net_device *out,
	     int (*okfn)(struct net *, struct sock *, struct sk_buff *))
{
	__skb_queue_head_init(sublist);
	/* Move everything to the sublist */
	skb_queue_splice_init(list, sublist);
}

-Ed
