From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 2/2] Interface group match - netfilter part
Date: Tue, 16 Oct 2007 10:30:10 +0200
Message-ID: <47147692.8070709@trash.net>
References: <1192521703479-git-send-email-panther@balabit.hu> <11925217031287-git-send-email-panther@balabit.hu> <11925217031728-git-send-email-panther@balabit.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: Laszlo Attila Toth <panther@balabit.hu>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <11925217031728-git-send-email-panther@balabit.hu>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Laszlo Attila Toth wrote:
> +static int match(const struct sk_buff *skb,
> +      const struct net_device *in,
> +      const struct net_device *out,
> +      const struct xt_match *match,
> +      const void *matchinfo,
> +      int offset,
> +      unsigned int protoff,
> +      int *hotdrop)
> +{
> +	const struct xt_ifgroup_info *info = matchinfo;
> +
> +	return ((in->ifgroup & info->mask) == info->group) ^ info->invert;

The input interface is only valid in PREROUTING, INPUT and FORWARD.
Why don't you support output-interface matching?

> +}
> +
> +static struct xt_match ifgroup_match = {
> +	.name		= "ifgroup",
> +	.match		= match,
> +	.matchsize	= sizeof(struct xt_ifgroup_info),
> +	.family		= AF_INET,
> +	.me		= THIS_MODULE,
> +};
> +
> +static struct xt_match ifgroup6_match = {
> +	.name		= "ifgroup",
> +	.match		= match,
> +	.matchsize	= sizeof(struct xt_ifgroup_info),
> +	.family		= AF_INET6,
> +	.me		= THIS_MODULE,
> +};

__read_mostly

> +
> +static int __init xt_ifgroup_init(void)
> +{
> +	int ret;
> +
> +	ret = xt_register_match(&ifgroup_match);

xt_register_matches please.
