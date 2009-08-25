From: Denys Fedoryschenko <denys@visp.net.lb>
Subject: Re: iproute2 / tbf with large burst seems broken again
Date: Tue, 25 Aug 2009 10:34:09 +0300
Message-ID: <200908251034.09581.denys@visp.net.lb>
References: <20090825062203.GA5381@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hosting.visp.net.lb ([194.146.153.11]:39322 "EHLO
	hosting.visp.net.lb" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754115AbZHYHg7 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Aug 2009 03:36:59 -0400
In-Reply-To: <20090825062203.GA5381@ff.dom.local>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday 25 August 2009 09:22:03 Jarek Poplawski wrote:

>
> Right, it's about an overflow and it was expected (theoretically) for
> very low rates (as for current times) while doing this resolution
> change. Probably this kind of warning should be useful if we expect
> there're more people who can actually use something like this yet ;-)
>
> Alas INT_MAX could still be not enough to prevent similar issues
> because in tbf_dequeue such a value (buffer) is increased with tokens.
> I guess we could try to change some variables to 64 bits there, but
> the main question is why anybody needs such strange settings today?
> Did you try e.g. to browse Internet with that rate and the buffer
> e.g. 1500kb or you punish some users only? ;-) Btw, why do you think
> 'buffer 2000kb' is better "for you" with that rate than e.g. 20kb?
>
> Thanks,
> Jarek P.
Life in Lebanon:
Backbone for ISP - $2200 per Mbit and higher.

Accounts 256Kbit/s cost $66/month in some areas.
96 Kbits/s for people with low income costs cheaper.

>From government "alternative" solution - pay $20 for 2GB, but they charge 
(without any understandable notice for non-tech end-user) extra traffic :-) 
Some people ending month with bills $200/month. Surprise!

Try to browse with 96Kbit/s? U can't actually on this days, with pages that 
weight up to 5-10Mbyte...

The only solution - first 2-10Mbyte, for example, for user will be transferred 
on high speed, let's say 512Kbit/s, but if he put downloads - he will have 
his 96Kbit/s. If he just browse occasionally, his large bucket will 
be "recharged" with 96 Kbit/s, and next page will open again fast.

That's how this TBF configuration that i show works. But sure if it is 
difficult to solve i will implement something similar in userspace, that will 
track user consumption, and just change discipline settings... but sure it 
will be different thing. Actually because there is noone else complained 
about this except me, i guess i have to solve it by myself. Because better 
resolution for high bandwidth traffic shaping much more important even for 
me :-)

