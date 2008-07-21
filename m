From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 20/31] netns ct: NOTRACK in netns
Date: Mon, 21 Jul 2008 19:08:43 +0200
Message-ID: <4884C29B.7060107@trash.net>
References: <20080721165028.GF13390@martell.zuzino.mipt.ru> <alpine.LNX.1.10.0807211901220.21244@fbirervta.pbzchgretzou.qr>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Alexey Dobriyan <adobriyan@gmail.com>, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org, dev@openvz.org, xemul@openvz.org,
	ebiederm@xmission.com, dlezcano@fr.ibm.com, benjamin.thery@bull.net
To: Jan Engelhardt <jengelh@medozas.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:42802 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751842AbYGURIp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jul 2008 13:08:45 -0400
In-Reply-To: <alpine.LNX.1.10.0807211901220.21244@fbirervta.pbzchgretzou.qr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jan Engelhardt wrote:
> On Monday 2008-07-21 18:50, Alexey Dobriyan wrote:
> 
>> +++ b/net/netfilter/xt_state.c
>> @@ -30,7 +31,7 @@ state_mt(const struct sk_buff *skb, const struct net_device *in,
>> 	enum ip_conntrack_info ctinfo;
>> 	unsigned int statebit;
>>
>> -	if (nf_ct_is_untracked(skb))
>> +	if (nf_ct_is_untracked(dev_net(in ? in : out), skb))
> 
> Does this even do the right thing? Given the forward path, where
> both in!=NULL and out!=NULL, why should it specifically be 'in'
> that is selected?

It doesn't matter, the namespace during forwaring is always
equal for the input and output devices.
