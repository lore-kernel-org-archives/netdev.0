From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 09/18] netfilter: ipv6: add IPv6 NAT support
Date: Thu, 23 Aug 2012 00:15:31 +0200 (MEST)
Message-ID: <Pine.GSO.4.63.1208230014420.5113@stinky-local.trash.net>
References: <1345434006-16549-1-git-send-email-kaber@trash.net>
 <1345434006-16549-10-git-send-email-kaber@trash.net>
 <alpine.LNX.2.01.1208201100340.6101@frira.zrqbmnf.qr>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Jan Engelhardt <jengelh@inai.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:63552 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756619Ab2HVWPc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Aug 2012 18:15:32 -0400
In-Reply-To: <alpine.LNX.2.01.1208201100340.6101@frira.zrqbmnf.qr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 20 Aug 2012, Jan Engelhardt wrote:

> On Monday 2012-08-20 05:39, Patrick McHardy wrote:
>> +static struct nf_hook_ops nf_nat_ipv6_ops[] __read_mostly = {
>> +	/* Before packet filtering, change destination */
>> +	{
>> +		.hook		= nf_nat_ipv6_in,
>> +		.owner		= THIS_MODULE,
>> +		.pf		= NFPROTO_IPV6,
>> +		.hooknum	= NF_INET_PRE_ROUTING,
>> +		.priority	= NF_IP_PRI_NAT_DST,
>
> NF_IP6_PRI_NAT_DST
>
>> +		.hook		= nf_nat_ipv6_out,
>> +		.owner		= THIS_MODULE,
>> +		.pf		= NFPROTO_IPV6,
>> +		.hooknum	= NF_INET_POST_ROUTING,
>> +		.priority	= NF_IP_PRI_NAT_SRC,
>
> IP6 too... (2 more occurrences)

Fixed, thanks.

>> +static void nf_nat_ipv6_csum_recalc(struct sk_buff *skb,
>> +				    u8 proto, void *data, __sum16 *check,
>> +				    int datalen, int oldlen)
>> +{
>> +	const struct ipv6hdr *ipv6h = ipv6_hdr(skb);
>> +	struct rt6_info *rt = (struct rt6_info *)skb_dst(skb);
>> +
>> +	if (skb->ip_summed != CHECKSUM_PARTIAL) {
>
> Maybe invert to == CHECKSUM_PARTIAL like in p06/18.

I didn't change the other patch.
