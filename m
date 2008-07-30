From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH v2 2/3] net_sched: Add accessor function for packet length
 for qdiscs
Date: Wed, 30 Jul 2008 13:52:01 +0200
Message-ID: <489055E1.1040100@trash.net>
References: <48904EB2.8060402@trash.net>	<20080730113727.GB6362@ff.dom.local>	<48905326.5050907@trash.net> <20080730.044851.135868050.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jarkao2@gmail.com, jussi.kivilinna@mbnet.fi, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:46177 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754058AbYG3LwF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jul 2008 07:52:05 -0400
In-Reply-To: <20080730.044851.135868050.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Patrick McHardy <kaber@trash.net>
> Date: Wed, 30 Jul 2008 13:40:22 +0200
> 
>> The reason why it translates it at all seems to be to not increase
>> the drops counter. Within a single qdisc this could be avoided by
>> other means easily, upper qdiscs would still increase the counter
>> when we return anything besides NET_XMIT_SUCCESS though.
>>
>> This means we need a new NET_XMIT return value to indicate this to
>> the upper qdiscs. So I'd suggest to introduce NET_XMIT_STOLEN,
>> return that to upper qdiscs and translate it to NET_XMIT_SUCCESS
>> in dev_queue_xmit, similar to NET_XMIT_BYPASS.
> 
> Maybe these NET_XMIT_* values being passed around should be a set of
> bits.
> 
> They could be composed of base meanings, combined with specific
> attributes.
> 
> So you could say "NET_XMIT_DROP | __NET_XMIT_NO_DROP_COUNT"
> 
> The attributes get masked out by the top-level ->enqueue() caller,
> such that the base meanings are the only thing that make their
> way up into the stack.
> 
> If it's only about communication within the qdisc tree, let's
> simply code it that way.

Thats a good suggestion. I think this should work.

