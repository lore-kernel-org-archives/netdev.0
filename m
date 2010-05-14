From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCHv2] netfilter: Remove skb_is_nonlinear check from	nf_conntrack_sip
Date: Fri, 14 May 2010 20:42:43 +0200
Message-ID: <4BED99A3.2050404@trash.net>
References: <20100514180138.GF15969@obsidianresearch.com> <4BED92AF.50704@trash.net> <20100514182601.GJ15969@obsidianresearch.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:50651 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756773Ab0ENSmo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 May 2010 14:42:44 -0400
In-Reply-To: <20100514182601.GJ15969@obsidianresearch.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jason Gunthorpe wrote:
> On Fri, May 14, 2010 at 08:13:03PM +0200, Patrick McHardy wrote:
>> Your patch is based on an old version, the current version also
>> supports TCP. I'll commit this patch to my tree after some testing.
> 
> Thanks!
> 
>> diff --git a/net/netfilter/nf_conntrack_sip.c b/net/netfilter/nf_conntrack_sip.c
>> index b20f427..45750cc 100644
>> +++ b/net/netfilter/nf_conntrack_sip.c
>> @@ -1393,10 +1393,8 @@ static int sip_help_tcp(struct sk_buff *skb, unsigned int protoff,
>>  
>>  	nf_ct_refresh(ct, skb, sip_timeout * HZ);
>>  
>> -	if (skb_is_nonlinear(skb)) {
>> -		pr_debug("Copy of skbuff not supported yet.\n");
>> +	if (unlikely(skb_linearize(skb)))
>>  		return NF_ACCEPT;
>> -	}
> 
> Should this be NF_DROP? As I understand it skb_linearize only failes
> if it runs out of memory, which probably means dropping is OK. But
> passing a packet that might need rewriting could be harmful..

We so far also didn't rewrite the packet. But agreed, its
a corner case and dropping it is the safer choice.
