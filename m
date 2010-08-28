From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] gro: Is it ok to share a single napi from several devs ?
Date: Sat, 28 Aug 2010 15:33:55 -0700 (PDT)
Message-ID: <20100828.153355.39175872.davem@davemloft.net>
References: <20100828101424.69c4c782@s6510>
	<20100828.144130.189711704.davem@davemloft.net>
	<20100828153124.0e76425f@nehalam>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, jarkao2@gmail.com,
	herbert@gondor.apana.org.au, netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51059
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752517Ab0H1Wdj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Aug 2010 18:33:39 -0400
In-Reply-To: <20100828153124.0e76425f@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Sat, 28 Aug 2010 15:31:24 -0700

> On Sat, 28 Aug 2010 14:41:30 -0700 (PDT)
> David Miller <davem@davemloft.net> wrote:
> 
>> Since netpoll does similar things, this means both NAPI and netpoll
>> cannot function properly with SKY2's second port.  It will only work
>> right on the first port.
> 
> I knew netpoll was broken on second port.

Well, now we know that GRO is too :-)

If we wish to keep the one-to-one mapping of NAPI contexts to
interrupt sources, what we can do is provide some kind of "dev list".

The other option is to register two NAPI contexts and schedule them
both on an interrupt.

But in both cases, detecting the end of polling, and thus when to turn
the interrupts back on, is non-trivial.

I really don't like either solution, therefore, so I'll try to brain
storm on this a bit more.
