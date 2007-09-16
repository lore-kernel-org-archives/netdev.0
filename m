From: jamal <hadi@cyberus.ca>
Subject: Re: [RFC][NET_SCHED] explict hold dev tx lock
Date: Sun, 16 Sep 2007 16:41:24 -0400
Message-ID: <1189975284.4230.14.camel@localhost>
References: <1189959274.4241.30.camel@localhost>
	 <20070916.123158.92582301.davem@davemloft.net>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org,
	kaber@trash.net, dada1@cosmosbay.com, johnpol@2ka.mipt.ru
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.231]:2300 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750780AbXIPUl2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 16 Sep 2007 16:41:28 -0400
Received: by wx-out-0506.google.com with SMTP id h31so1179316wxd
        for <netdev@vger.kernel.org>; Sun, 16 Sep 2007 13:41:27 -0700 (PDT)
In-Reply-To: <20070916.123158.92582301.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 2007-16-09 at 12:31 -0700, David Miller wrote:
> From: jamal <hadi@cyberus.ca>
> Date: Sun, 16 Sep 2007 12:14:34 -0400

> > So - what side effects do people see in doing this? If none, i will
> > clean it up and submit.
> 
> I tried this 4 years ago, it doesn't work.  :-)
> 

;->

[good reasons removed here]

> I don't think we want to do it anyways, whatever performance
> we gain from it is offset by the badness of disabling interrupts
> during this reasonably length stretch of code.
> 
> The -rt folks as a result would notice this too and spank us :-)

indeed. 
Ok, maybe i am thinking too hard with that patch, so help me out:->
When i looked at that code path as it is today: i felt the softirq could
be interupted on the same CPU it is running on while it already grabbed
that tx lock (if the trylock succeeds) and that the hardirq code when
attempting to grab the lock would result in a deadlock.
Did i misread that? 
When i experimented with tg3 and e1000 i did not see any such problems
with the non irq version of the lock.

cheers,
jamal

