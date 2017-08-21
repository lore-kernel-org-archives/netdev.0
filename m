From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv3 net-next] gre: introduce native tunnel support for
 ERSPAN
Date: Mon, 21 Aug 2017 11:02:26 -0700 (PDT)
Message-ID: <20170821.110226.325505016722205417.davem@davemloft.net>
References: <1503062680-43972-1-git-send-email-u9012063@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mvohra@vmware.com, kuznet@ms2.inr.ac.ru,
        yoshfuji@linux-ipv6.org
To: u9012063@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:37960 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752744AbdHUSC1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 21 Aug 2017 14:02:27 -0400
In-Reply-To: <1503062680-43972-1-git-send-email-u9012063@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: William Tu <u9012063@gmail.com>
Date: Fri, 18 Aug 2017 06:24:40 -0700

> +static int erspan_rcv(struct sk_buff *skb, struct tnl_ptk_info *tpi,
> +		      int gre_hdr_len)
> +{
> +	struct net *net = dev_net(skb->dev);
> +	struct ip_tunnel_net *itn;
> +	struct ip_tunnel *tunnel;
> +	struct metadata_dst *tun_dst = NULL;
> +	const struct iphdr *iph;
> +	struct erspanhdr *ershdr;
> +	__be32 index;
> +	__be32 session_id;
> +	int len;

Please order local variables from longest to shortest line, ie. reverse
christmas tree format.

> +
> +	itn = net_generic(net, erspan_net_id);
> +	iph = ip_hdr(skb);
> +	len =  iph->ihl * 4 + gre_hdr_len + sizeof(*ershdr);
> +
> +	if (unlikely(!pskb_may_pull(skb, len)))
> +		return -ENOMEM;

I think the len passed here is wrong, it should be
"gre_hdr_len + sizeof(*ershdr)".
> +static void erspan_build_header(struct sk_buff *skb,
> +				__be32 id, u32 index, bool truncate)
> +{
> +	struct erspanhdr *ershdr;
> +	struct iphdr *iphdr = ip_hdr(skb);
> +	struct ethhdr *eth = eth_hdr(skb);
> +	struct qtag_prefix {
> +		__be16 eth_type;
> +		__be16 tci;
> +	} *qp;
> +	u16 vlan_tci = 0;
> +	enum erspan_encap_type enc_type = ERSPAN_ENCAP_NOVLAN;

Reverse christmas tree for the local variables, please.

> +static int erspan_validate(struct nlattr *tb[], struct nlattr *data[],
> +			   struct netlink_ext_ack *extack)
> +{
> +	int ret;
> +	__be16 flags = 0;

Likewise.
