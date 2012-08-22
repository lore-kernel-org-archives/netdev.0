From: Jan Engelhardt <jengelh@inai.de>
Subject: Re: [PATCH 06/18] netfilter: add protocol independant NAT core
Date: Thu, 23 Aug 2012 00:48:19 +0200 (CEST)
Message-ID: <alpine.LNX.2.01.1208230045480.22098@frira.zrqbmnf.qr>
References: <1345434006-16549-1-git-send-email-kaber@trash.net> <1345434006-16549-7-git-send-email-kaber@trash.net> <alpine.LNX.2.01.1208201011480.6101@frira.zrqbmnf.qr> <Pine.GSO.4.63.1208230008220.5113@stinky-local.trash.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <Pine.GSO.4.63.1208230008220.5113@stinky-local.trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Thursday 2012-08-23 00:13, Patrick McHardy wrote:
>>> +	iph = (void *)skb->data + iphdroff;
>>
>> Is trying to avoid some GNU extensions a worthwhile goal? If so,
>> iph = (struct iphdr *)(skb->data + iphdroff) should be used, like in:
>
> I don't get your point.

You are doing arithmetic with a void* pointer, which is a GNU extension.
Should we try to limit "unnecessary excess usage" of GNU features?
You could do arithmetic with the char* that skb->data is:

 iph = (void *)(skb->data + iphdroff);

or, if more clarity is desired, the more verbose form

 iph = (struct iphdr *)(skb->data + iphdroff);

Does this seem like something worthwhile to passively pursue?
