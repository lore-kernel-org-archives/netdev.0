From: jamal <hadi@cyberus.ca>
Subject: Re: Network card IRQ balancing with Intel 5000 series chipsets
Date: Tue, 26 Dec 2006 17:46:39 -0500
Message-ID: <1167173199.3746.45.camel@localhost>
References: <7e63f56c0612240134s452f6510h8483fb31e5efe799@mail.gmail.com>
	 <1167039303.3281.1574.camel@laptopd505.fenrus.org>
	 <7e63f56c0612250326td172f28n532435b23d18b69f@mail.gmail.com>
	 <1167046499.3281.1623.camel@laptopd505.fenrus.org>
	 <7e63f56c0612250454g5520bd6aja0fb9ab2656ff74e@mail.gmail.com>
	 <1167158658.3746.12.camel@localhost>
	 <1167170793.3281.3209.camel@laptopd505.fenrus.org>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Robert Iakobashvili <coroberti@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.238]:18969 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932831AbWLZWqn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Dec 2006 17:46:43 -0500
Received: by wx-out-0506.google.com with SMTP id h27so4000777wxd
        for <netdev@vger.kernel.org>; Tue, 26 Dec 2006 14:46:42 -0800 (PST)
To: Arjan van de Ven <arjan@infradead.org>
In-Reply-To: <1167170793.3281.3209.camel@laptopd505.fenrus.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2006-26-12 at 23:06 +0100, Arjan van de Ven wrote:

> it is; that's why irqbalance tries really hard (with a few very rare
> exceptions) to keep networking irqs to the same cpu all the time...
> 

The problem with irqbalance when i last used it is it doesnt take into
consideration CPU utilization. 
With NAPI, if i have a few interupts it likely implies i have a huge
network load (and therefore CPU use) and would be much more happier if
you didnt start moving more interupt load to that already loaded CPU....
So if you start considering CPU load sampled over a period of time, you
could make some progress. 

> but if your use case is kernel level packet processing of < MTU packets
> then I can see why you would at some point would run out of cpu
> power ... 

Of course, otherwise there would be not much value in "balancing" ..

Note < MTU sized packets is not unusual for firewall/router middle boxen
and theres plenty of those out there. But these days for VOIP endpoints
(RTP and SIP) which may process such packets in user space (and handle
thousands of such flows).
Additional note: the average packet size on the internet today (and for
many years) is way below your standard ethernet MTU of 1500 bytes.
 
> esp on multicore where you share the cache between cores you
> probably can do a little better for that very specific use case.

Indeed - thats why i proposed to tie the IRQs statically. Modern
machines have much larger caches, so static config is less of a
nuisance.

cheers,
jamal

