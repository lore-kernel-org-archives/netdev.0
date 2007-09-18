From: jamal <hadi@cyberus.ca>
Subject: Re: [RFC][NET_SCHED] explict hold dev tx lock
Date: Mon, 17 Sep 2007 22:48:48 -0400
Message-ID: <1190083728.4237.59.camel@localhost>
References: <1189959274.4241.30.camel@localhost>
	 <20070916.123158.92582301.davem@davemloft.net>
	 <1189975284.4230.14.camel@localhost>
	 <20070917.190133.79431533.davem@davemloft.net>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org,
	kaber@trash.net, dada1@cosmosbay.com, johnpol@2ka.mipt.ru
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from an-out-0708.google.com ([209.85.132.246]:56696 "EHLO
	an-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754617AbXIRCsx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Sep 2007 22:48:53 -0400
Received: by an-out-0708.google.com with SMTP id d31so261036and
        for <netdev@vger.kernel.org>; Mon, 17 Sep 2007 19:48:52 -0700 (PDT)
In-Reply-To: <20070917.190133.79431533.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2007-17-09 at 19:01 -0700, David Miller wrote:

> Hardirq should never try to grab the netif_tx_lock(), it is
> only for base and softirq context.
> 
> Any hardirq context code taking that lock needs to be fixed.
> We could assert this if we don't already.

I snooped around it looks pretty clean;  An assertion wont hurt,
but people will find _very quickly_ it hurts when testing a driver if
they did it wrong;->

> It's the only way that it works that we can invoke ->hard_start_xmit()
> with interrupts fully enabled.

> I notice that your patch bypasses the LLTX logic (I think) and this
> isn't kosher, it might introduce deadlocks or similar as when we
> are doing LLTX the driver determines the locking and IRQ context
> semantics.

Nothing much has changed from what it was before.
The only difference is we let go of the queue lock before grabbing
the tx lock which never mattered for LLTX. 
Once we grab the tx lock it is the same logic and so far is working well
on both tg3 and e1000 (which is LLTX). 
I will continue to retest with net-2.6.24 once you complete rebasing
and look around to see if anyone maybe affected.

cheers,
jamal

