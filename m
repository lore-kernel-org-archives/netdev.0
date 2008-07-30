From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH v2 2/3] net_sched: Add accessor function for packet
	length for qdiscs
Date: Wed, 30 Jul 2008 12:19:21 +0000
Message-ID: <20080730121921.GC6362@ff.dom.local>
References: <48904EB2.8060402@trash.net> <20080730113727.GB6362@ff.dom.local> <48905326.5050907@trash.net> <20080730.044851.135868050.davem@davemloft.net> <489055E1.1040100@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, jussi.kivilinna@mbnet.fi,
	netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.169]:39673 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752852AbYG3MOH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jul 2008 08:14:07 -0400
Received: by ug-out-1314.google.com with SMTP id h2so245726ugf.16
        for <netdev@vger.kernel.org>; Wed, 30 Jul 2008 05:14:05 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <489055E1.1040100@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 30, 2008 at 01:52:01PM +0200, Patrick McHardy wrote:
> David Miller wrote:
>> From: Patrick McHardy <kaber@trash.net>
>> Date: Wed, 30 Jul 2008 13:40:22 +0200
>>
>>> The reason why it translates it at all seems to be to not increase
>>> the drops counter. Within a single qdisc this could be avoided by
>>> other means easily, upper qdiscs would still increase the counter
>>> when we return anything besides NET_XMIT_SUCCESS though.
>>>
>>> This means we need a new NET_XMIT return value to indicate this to
>>> the upper qdiscs. So I'd suggest to introduce NET_XMIT_STOLEN,
>>> return that to upper qdiscs and translate it to NET_XMIT_SUCCESS
>>> in dev_queue_xmit, similar to NET_XMIT_BYPASS.
>>
>> Maybe these NET_XMIT_* values being passed around should be a set of
>> bits.
>>
>> They could be composed of base meanings, combined with specific
>> attributes.
>>
>> So you could say "NET_XMIT_DROP | __NET_XMIT_NO_DROP_COUNT"
>>
>> The attributes get masked out by the top-level ->enqueue() caller,
>> such that the base meanings are the only thing that make their
>> way up into the stack.
>>
>> If it's only about communication within the qdisc tree, let's
>> simply code it that way.
>
> Thats a good suggestion. I think this should work.
>

Yes, very nice! (I guess I can look at this more...)

Jarek P.
