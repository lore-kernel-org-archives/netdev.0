From: Vladimir Ivashchenko <hazard@francoudi.com>
Subject: Re: HTB accuracy for high speed
Date: Thu, 21 May 2009 10:44:00 +0300
Message-ID: <20090521074400.GA19113@francoudi.com>
References: <20090516141430.GB3013@ami.dom.local> <298f5c050905180736m303f0c79ha30d3f791222fa1b@mail.gmail.com> <1242688479.9558.60.camel@hazard2.francoudi.com> <1242689267.11814.1.camel@hazard2.francoudi.com> <20090519110311.GA5521@ff.dom.local> <20090519140416.GA21270@francoudi.com> <20090519201027.GA4751@ami.dom.local> <1242857245.13519.17.camel@hazard2.francoudi.com> <4A148838.8010809@cosmosbay.com> <20090521072050.GA2892@ami.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <dada1@cosmosbay.com>, netdev@vger.kernel.org,
	kaber@trash.net, davem@davemloft.net, devik@cdi.cz,
	Antonio Almeida <vexwek@gmail.com>,
	Corey Hickey <bugfood-ml@fatooh.org>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cerber.thunderworx.net ([217.27.32.18]:2795 "EHLO
	cerber.thunderworx.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751506AbZEUHoF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 May 2009 03:44:05 -0400
Content-Disposition: inline
In-Reply-To: <20090521072050.GA2892@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> I don't know why more of esfq wasn't merged, anyway similar
> functionality could be achieved in current kernels with sch_drr +
> cls_flow, alas not enough documented. Here is some hint:
> http://markmail.org/message/h24627xkrxyqxn4k

Can I balance only by destination IP using this approach? 
Normal IP flow-based balancing is not good for me, I need 
to ensure equality between destination hosts.

> 
> Jarek P.
> 
> PS: I guess, you wasn't very consistent if your main problem was
> exceeding or not reaching htb rate, and there is quite a difference.

Yes indeed :(

I'm trying to migrate from 2.6.21 eth/htb/esfq to 2.6.29 
bond/htb/sfq, and that introduces a lot of changes.

Apparently during some point I changed sfq divisor from 1024 
to 2048 and forgot about it.

Now I realize that the problems I reported were as follows:

1) HTB exceeds target when I use HTB + sfq + divisor 1024
2) HFSC exceeds target when I use HFSC + sfq + divisor 1024
3) HTB does not reach target when I use HTB + sfq + divisor 2048

I will check again scenario 1) with the latest patches from
the list.

> Vladimir Ivashchenko wrote, On 05/08/2009 10:46 PM:
> 
> > Exporting HZ=1000 doesn't help. However, even if I recompile the kernel
> > to 1000 Hz and the burst is calculated correctly, for some reason HTB on
> > 2.6.29 is still worse at rate control than 2.6.21.
> > 
> > With 2.6.21, ceil of 775 mbits, burst 99425b -> actual rate 825 mbits.
> > With 2.6.29, same ceil/burst -> actual rate 890 mbits.
> ...
> 
> Vladimir Ivashchenko wrote, On 05/17/2009 10:29 PM:
> 
> > Hi Antonio,
> > 
> > FYI, these are exactly the same problems I get in real life.
> > Check the later posts in "bond + tc regression" thread.
> ...

-- 
Best Regards
Vladimir Ivashchenko
Chief Technology Officer
PrimeTel, Cyprus - www.prime-tel.com
