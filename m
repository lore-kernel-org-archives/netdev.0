From: David Miller <davem@davemloft.net>
Subject: Re: OFT - reserving CPU's for networking
Date: Sat, 01 May 2010 15:03:38 -0700 (PDT)
Message-ID: <20100501.150338.93457735.davem@davemloft.net>
References: <20100430210131.GA2833@gargoyle.fritz.box>
	<20100430.153038.62351857.davem@davemloft.net>
	<20100501105304.GA9434@gargoyle.fritz.box>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tglx@linutronix.de, shemminger@vyatta.com, eric.dumazet@gmail.com,
	netdev@vger.kernel.org, peterz@infradead.org
To: andi@firstfloor.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52651
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756654Ab0EAWDc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 1 May 2010 18:03:32 -0400
In-Reply-To: <20100501105304.GA9434@gargoyle.fritz.box>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andi Kleen <andi@firstfloor.org>
Date: Sat, 1 May 2010 12:53:04 +0200

>> And we don't want it to, because the decision mechanisms for steering
>> that we using now are starting to get into the stateful territory and
>> that's verbotton for NIC offload as far as we're concerned.
> 
> Huh? I thought full TCP offload was forbidden?[1] Statefull as in NIC 
> (or someone else like netfilter) tracking flows is quite common and very far 
> from full offload. AFAIK it doesn't have near all the problems full
> offload has.

We're tracking flow cpu location state at the socket operations, like
recvmsg() and sendmsg(), where it belongs.

Would you like us to call into the card drivers and firmware at these
spots instead?
