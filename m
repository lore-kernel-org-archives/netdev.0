From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] [PATCH] Avoid enqueuing skb for default qdiscs
Date: Mon, 03 Aug 2009 20:29:35 -0700 (PDT)
Message-ID: <20090803.202935.221338243.davem@davemloft.net>
References: <20090728155055.2266.41649.sendpatchset@localhost.localdomain>
	<OF4A7A6701.1BD183E8-ON65257604.0024A9E1-65257606.0030A90D@in.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, jarkao2@gmail.com, kaber@trash.net,
	netdev@vger.kernel.org
To: krkumar2@in.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43546
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755186AbZHDD31 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Aug 2009 23:29:27 -0400
In-Reply-To: <OF4A7A6701.1BD183E8-ON65257604.0024A9E1-65257606.0030A90D@in.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Krishna Kumar2 <krkumar2@in.ibm.com>
Date: Sun, 2 Aug 2009 14:21:30 +0530

> Krishna Kumar2/India/IBM@IBMIN wrote on 07/28/2009 09:20:55 PM:
> 
>> Subject [RFC] [PATCH] Avoid enqueuing skb for default qdiscs
>>
>> From: Krishna Kumar <krkumar2@in.ibm.com>
>>
>> dev_queue_xmit enqueue's a skb and calls qdisc_run which
>> dequeue's the skb and xmits it. In most cases (after
>> instrumenting the code), the skb that is enqueue'd is the
>> same one that is dequeue'd (unless the queue gets stopped
>> or multiple cpu's write to the same queue and ends in a
>> race with qdisc_run). For default qdiscs, we can remove
>> this path and simply xmit the skb since this is a work
>> conserving queue.
> 
> Any comments on this patch?

Although PFIFO is not work-conserving, isn't it important to retain
ordering?  What if higher priority packets are in the queue when we
enqueue?  This new bypass will send the wrong packet, won't it?

I'm beginning to think, if we want to make the default case go as fast
as possible, we should just bypass everything altogether.  The entire
qdisc layer, all of it.

Special casing something that essentially is unused, is in a way
a waste of time.  If this bypass could be applied to some of the
complicated qdiscs, then it'd be worthwhile, but just for the
default which effectively makes it do nothing, I don't see that
value in it.
