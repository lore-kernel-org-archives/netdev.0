From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Can I limit the number of active tx per TCP socket?
Date: Thu, 06 Mar 2014 11:27:06 -0800
Message-ID: <1394134026.27473.45.camel@edumazet-glaptop2.roam.corp.google.com>
References: <063D6719AE5E284EB5DD2968C1650D6D0F6D3B91@AcuExch.aculab.com>
	 <5318ADB1.5050107@hp.com>
	 <CADVnQyn1+WRqS9HQmMn9JgpBz0Wajg=40yVhdyqv_AAo4tpWUA@mail.gmail.com>
	 <5318C71C.1020807@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Neal Cardwell <ncardwell@google.com>,
	David Laight <David.Laight@aculab.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f50.google.com ([209.85.160.50]:39787 "EHLO
	mail-pb0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750988AbaCFT1N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Mar 2014 14:27:13 -0500
Received: by mail-pb0-f50.google.com with SMTP id md12so3033380pbc.37
        for <netdev@vger.kernel.org>; Thu, 06 Mar 2014 11:27:12 -0800 (PST)
In-Reply-To: <5318C71C.1020807@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2014-03-06 at 11:06 -0800, Rick Jones wrote:
> On 03/06/2014 10:09 AM, Neal Cardwell wrote:
> > Eric's recent "auto corking" feature may be helpful in this context:
> >
> >    http://lwn.net/Articles/576263/
> 
> Doesn't that depend on the bottleneck being local to the sending side? 
> Perhaps I've mis-understood David's setup, but I get the impression the 
> bottleneck is not at the sending side but either in the middle or at the 
> end, so tx completions will still be happening quickly.

There were multiple aspects.

One skb per flow in qdisc/TX ring : TCP Small Queue spirit (recently
kind of broken by commit 98e09386c0ef4dfd ("tcp: tsq: restore minimal
amount of queueing ")

FQ adds the Fairness part (bulk flows wont slow down interactive flows)

Then if the problem is having a high speed interface on the sender,
and a low speed receiver (or bottleneck), then SO_MAX_PACING_RATE is an
easy way to solve the problem. Only flows setting this option will be
paced, while others can use all the bandwidth they need.
