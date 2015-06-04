From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [RFC net-next 2/6] net: Identfier Locator Addressing module
Date: Thu, 4 Jun 2015 10:58:05 +0200
Message-ID: <20150604085805.GA1454@pox.localdomain>
References: <1433361502-3478761-1-git-send-email-tom@herbertland.com>
 <1433361502-3478761-3-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, agartrell@fb.com, maheshb@google.com,
	netdev@vger.kernel.org
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f177.google.com ([209.85.212.177]:38188 "EHLO
	mail-wi0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752363AbbFDI6J (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Jun 2015 04:58:09 -0400
Received: by wibdt2 with SMTP id dt2so41348133wib.1
        for <netdev@vger.kernel.org>; Thu, 04 Jun 2015 01:58:08 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1433361502-3478761-3-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/03/15 at 12:58pm, Tom Herbert wrote:
> +static struct genl_family ila_nl_family = {
> +	.id		= GENL_ID_GENERATE,
> +	.hdrsize	= 0,
> +	.name		= ILA_GENL_NAME,
> +	.version	= ILA_GENL_VERSION,
> +	.maxattr	= ILA_ATTR_MAX,
> +	.netnsok	= true,
> +};

Since you have bucket locks, you might want to see if you can
enable .parallel_ops = true to speed up the rate of map updates.

Use of rhashtable is another obvious consideration.

> +static int ila_nl_cmd_get_mapping(struct sk_buff *skb, struct genl_info *info)
> +{
> +	struct net *net = genl_info_net(info);
> +	struct ila_net *ilan = net_generic(net, ila_net_id);
> +	struct sk_buff *msg;
> +	struct ila_cfg cfg;
> +	struct ila_map *ila;
> +	int ret;
> +
> +	ret = parse_nl_config(info, &cfg);
> +	if (ret)
> +		return ret;
> +
> +	msg = nlmsg_new(NLMSG_DEFAULT_SIZE, GFP_KERNEL);
> +	if (!msg)
> +		return -ENOMEM;

Since the message size is actually really small it might be worth
to calculate it accurately here to speed up the get.

> +#define ILA_HASH_TABLE_SIZE 1024

Already defined at the top.
