From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: HTB accuracy for high speed
Date: Thu, 21 May 2009 10:28:05 +0200
Message-ID: <20090521082805.GB2892@ami.dom.local>
References: <298f5c050905180736m303f0c79ha30d3f791222fa1b@mail.gmail.com> <1242688479.9558.60.camel@hazard2.francoudi.com> <1242689267.11814.1.camel@hazard2.francoudi.com> <20090519110311.GA5521@ff.dom.local> <20090519140416.GA21270@francoudi.com> <20090519201027.GA4751@ami.dom.local> <1242857245.13519.17.camel@hazard2.francoudi.com> <4A148838.8010809@cosmosbay.com> <20090521072050.GA2892@ami.dom.local> <20090521074400.GA19113@francoudi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <dada1@cosmosbay.com>, netdev@vger.kernel.org,
	kaber@trash.net, davem@davemloft.net, devik@cdi.cz,
	Antonio Almeida <vexwek@gmail.com>,
	Corey Hickey <bugfood-ml@fatooh.org>
To: Vladimir Ivashchenko <hazard@francoudi.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f222.google.com ([209.85.218.222]:43531 "EHLO
	mail-bw0-f222.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751042AbZEUI2a (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 May 2009 04:28:30 -0400
Received: by bwz22 with SMTP id 22so863998bwz.37
        for <netdev@vger.kernel.org>; Thu, 21 May 2009 01:28:31 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20090521074400.GA19113@francoudi.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 21, 2009 at 10:44:00AM +0300, Vladimir Ivashchenko wrote:
> > I don't know why more of esfq wasn't merged, anyway similar
> > functionality could be achieved in current kernels with sch_drr +
> > cls_flow, alas not enough documented. Here is some hint:
> > http://markmail.org/message/h24627xkrxyqxn4k
> 
> Can I balance only by destination IP using this approach? 
> Normal IP flow-based balancing is not good for me, I need 
> to ensure equality between destination hosts.

Yes, you need to use flow "dst" key, I guess. (tc filter add flow help)

Jarek P.

> > PS: I guess, you wasn't very consistent if your main problem was
> > exceeding or not reaching htb rate, and there is quite a difference.
> 
> Yes indeed :(

Generally, the most common reasons are:
- too short (or zero) tx queue length or/plus some disturbances in
  maintaining the flow - for not reaching the rate
- gso/tso or other non standard packets sizes - for exceeding the
  rate.
