From: Jan Engelhardt <jengelh@computergmbh.de>
Subject: Re: [PATCH 2/2] Interface group match - netfilter part
Date: Tue, 16 Oct 2007 16:46:43 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.0710161645420.10197@fbirervta.pbzchgretzou.qr>
References: <1192521703479-git-send-email-panther@balabit.hu>
 <11925217031287-git-send-email-panther@balabit.hu>
 <11925217031728-git-send-email-panther@balabit.hu> <47147692.8070709@trash.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Laszlo Attila Toth <panther@balabit.hu>, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <47147692.8070709@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Oct 16 2007 10:30, Patrick McHardy wrote:

>> +static int match(const struct sk_buff *skb,

Potential symbol clash, name it ifgroup_match() for example.

>> +      const struct net_device *in,
>> +      const struct net_device *out,
>> +      const struct xt_match *match,
>> +      const void *matchinfo,
>> +      int offset,
>> +      unsigned int protoff,
>> +      int *hotdrop)

2.6.23 => bool ifgroup_match(... bool *hotdrop)

>> +static struct xt_match ifgroup_match = {
>> +	.name		= "ifgroup",
>> +	.match		= match,
>> +	.matchsize	= sizeof(struct xt_ifgroup_info),
>> +	.family		= AF_INET,
>> +	.me		= THIS_MODULE,
>> +};
>> +
>> +static struct xt_match ifgroup6_match = {
>> +	.name		= "ifgroup",
>> +	.match		= match,
>> +	.matchsize	= sizeof(struct xt_ifgroup_info),
>> +	.family		= AF_INET6,
>> +	.me		= THIS_MODULE,
>> +};
>
> __read_mostly

And actually, an array,

	static struct xt_match ifgroup_match[] __read_mostly = {
		...
	}

