From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [RFC net-next 3/4] openvswitch: Add conntrack action.
Date: Sat, 14 Feb 2015 19:56:07 +0000
Message-ID: <20150214195607.GA30752@casper.infradead.org>
References: <1423901633-53789-1-git-send-email-joestringer@nicira.com>
 <1423901633-53789-4-git-send-email-joestringer@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Justin Pettit <jpettit@nicira.com>,
	Pablo Neira Ayuso <pablo@netfilter.org>, dev@openvswitch.org
To: Joe Stringer <joestringer@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:42493 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754179AbbBNT4K (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Feb 2015 14:56:10 -0500
Content-Disposition: inline
In-Reply-To: <1423901633-53789-4-git-send-email-joestringer@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/14/15 at 12:13am, Joe Stringer wrote:

[..]

> +static bool skb_has_valid_nfct(const struct net *net, u16 zone,
> +			       const struct sk_buff *skb)
> +{
> +	enum ip_conntrack_info ctinfo;
> +	struct nf_conn *ct = nf_ct_get(skb, &ctinfo);
> +
> +	if (!ct)
> +		return false;
> +	if (!net_eq(net, ct->ct_net))
> +		return false;

I'm surprised that this is needed. Shouldn't we call skb_scrub_packet()
between namespaces and invalidate the ct associated with the skb.
