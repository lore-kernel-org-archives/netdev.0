From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: TCP and reordering
Date: Wed, 28 Nov 2012 04:52:20 -0800
Message-ID: <1354107140.14302.140.camel@edumazet-glaptop>
References: <CAAeewD8zsfb6QPFecvPab_oK3D3T7eG_M53MVvfJ2QrxUFxWSQ@mail.gmail.com>
	 <50B4F2DA.8020206@hp.com>
	 <CAAeewD9MtEx4uF6ezbBj7Ci5OzX8VK7p=WQ2TB3PfjmznA4X0w@mail.gmail.com>
	 <20121127.210611.1127622873924794001.davem@davemloft.net>
	 <1354089566.21562.20.camel@shinybook.infradead.org>
	 <CAGK4HS8=NfcyvcNjC3h1wEjgQFCYoNeuWXj8n5Ruukeg+6j=SQ@mail.gmail.com>
	 <1354093703.21562.23.camel@shinybook.infradead.org>
	 <1354100552.14302.78.camel@edumazet-glaptop>
	 <1354103355.21562.46.camel@shinybook.infradead.org>
	 <1354105619.14302.89.camel@edumazet-glaptop>
	 <1354106362.21562.51.camel@shinybook.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Vijay Subramanian <subramanian.vijay@gmail.com>,
	David Miller <davem@davemloft.net>, saku@ytti.fi,
	rick.jones2@hp.com, netdev@vger.kernel.org
To: David Woodhouse <dwmw2@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ia0-f174.google.com ([209.85.210.174]:45803 "EHLO
	mail-ia0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754660Ab2K1MwY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Nov 2012 07:52:24 -0500
Received: by mail-ia0-f174.google.com with SMTP id y25so9827812iay.19
        for <netdev@vger.kernel.org>; Wed, 28 Nov 2012 04:52:23 -0800 (PST)
In-Reply-To: <1354106362.21562.51.camel@shinybook.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-11-28 at 12:39 +0000, David Woodhouse wrote:

> 
> I'll go back to looking at TSQ, and BQL for PPP. If I have to use
> skb_orphan() and install a destructor of my own in order to do BQL for
> PPP, that'll upset TSQ a little. Is there a way we could *chain* the
> destructors... skb_clone() to put the skbs on the PPP channels' queues,
> perhaps, then free the original from the PPP destructor? Or is that too
> much overhead?
> 
> I've killed most of the channel queue for PPPoATM and PPPoE now, but
> L2TP still has a whole load of buffering all the way through the stack
> again before it really leaves the host.
> 
> (And PPPoE will still have the txqueuelen on the Ethernet device too).
> 

BQL is nice for high speed adapters.

For slow one, you always can stop the queue for each packet given to
start_xmit()

And restart the queue at TX completion.

Some device drivers do that (because the hardware has a single slot, no
ring buffer, not because they wanted to fight bufferbloat ;) )
