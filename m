From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH v2 2/3] net_sched: Add accessor function for packet	length
 for qdiscs
Date: Wed, 30 Jul 2008 13:40:22 +0200
Message-ID: <48905326.5050907@trash.net>
References: <20080725105748.GB10399@ff.dom.local> <20080725.035712.33516738.davem@davemloft.net> <20080725113757.GC10399@ff.dom.local> <20080725.044928.261427957.davem@davemloft.net> <488B24E6.4020003@trash.net> <20080726141844.GB2873@ami.dom.local> <489046C3.5030208@trash.net> <20080730111915.GA6362@ff.dom.local> <48904EB2.8060402@trash.net> <20080730113727.GB6362@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, jussi.kivilinna@mbnet.fi,
	netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:45912 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751548AbYG3LkZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jul 2008 07:40:25 -0400
In-Reply-To: <20080730113727.GB6362@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jarek Poplawski wrote:
> On Wed, Jul 30, 2008 at 01:21:22PM +0200, Patrick McHardy wrote:
>> Jarek Poplawski wrote:
> ...
>>> I thought it needs to wait for your audit. (Considering current
>>> state of NET_XMIT statuses it's simple and reliable.) Otherwise
>>> I'd prefer nice methods too.
>>>   
>> Well, the problems are already clear, someone just needs to fix them :)
>> I won't be able to do this until next week.
> 
> ...alas to me the solution looks less clear...

The reason why it translates it at all seems to be to not increase
the drops counter. Within a single qdisc this could be avoided by
other means easily, upper qdiscs would still increase the counter
when we return anything besides NET_XMIT_SUCCESS though.

This means we need a new NET_XMIT return value to indicate this to
the upper qdiscs. So I'd suggest to introduce NET_XMIT_STOLEN,
return that to upper qdiscs and translate it to NET_XMIT_SUCCESS
in dev_queue_xmit, similar to NET_XMIT_BYPASS.

