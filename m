From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH][NETFILTER]: fix inconsistent lock state in	nf_ct_frag6_gather()
Date: Mon, 02 Jun 2008 15:24:02 +0200
Message-ID: <4843F472.1000306@trash.net>
References: <20080529120248.GA9702@alice> <20080530105334.GA7378@ff.dom.local> <20080530211315.GA16064@alice> <20080530215314.GA2485@ami.dom.local> <4843CEDE.8030409@trash.net> <20080602124500.GA4463@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Eric Sesterhenn <snakebyte@gmx.de>, netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:37587 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752522AbYFBNYI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Jun 2008 09:24:08 -0400
In-Reply-To: <20080602124500.GA4463@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jarek Poplawski wrote:
> On Mon, Jun 02, 2008 at 12:43:42PM +0200, Patrick McHardy wrote:
>> Jarek Poplawski wrote:
>>> According to this and another similar lockdep report inet_fragment
>>> locks are taken from nf_ct_frag6_gather() with softirqs enabled, but
>>> these locks are mainly used in softirq context, so disabling BHs is
>>> necessary.
>> Yes, this can happen on the local output path,
>>
>>> David & Patrick,
>>>
>>> It looks like this patch could be applied.
>> Looks mostly fine, but don't we also have to disable BHs for
>> the inet_frag_find() call in nf_ct_frag6_gather()?
>>
> 
> Probably I miss something, but I think this patch seems to do it:
> I can see only one such call in nf_ct_frag6_gather() - with
> fq_find()?

Right, I missed that, sorry.

> BTW, it looks like this lockdep warning points at some other possible
> problem: inet_fragment.c uses an SMP "optimization" in
> inet_frag_intern(), probably assuming softirq context; so without such
> BH blocking around inet_frag_find(), there should be at least
> preemption disabled, but I don't know if it's a problem for nf_ct.

Yes, good catch. With your patch things should be fine however.

I've applied your patch and will also push it to -stable.
