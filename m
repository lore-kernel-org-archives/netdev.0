From: Miroslav Urbanek <mu@miroslavurbanek.com>
Subject: Re: [PATCH] flowcache: Fix kernel panic in flow_cache_flush_task
Date: Thu, 5 Feb 2015 18:40:51 +0100
Message-ID: <20150205174026.GC3350@miroslavurbanek.com>
References: <20150205153649.GA3278@miroslavurbanek.com>
 <1423154648.31870.81.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Steffen Klassert <steffen.klassert@secunet.com>,
	Netdev <netdev@vger.kernel.org>,
	=?utf-8?B?VG9tw6HFoSBDaGFydsOhdA==?= <tc@excello.cz>,
	Jan Hejl <jh@excello.cz>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from antirelay20.smtp.cz ([81.95.105.150]:51594 "EHLO
	antirelay20.smtp.cz" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750884AbbBERlD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Feb 2015 12:41:03 -0500
Content-Disposition: inline
In-Reply-To: <1423154648.31870.81.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks for the tip. It's my first kernel patch, so I wanted to make
sure it won't get lost :-)

Anyway, I also looked into the function flow_cache_fini. Isn't it
necessary to flush/cancel scheduled works here? Something like:

flush_work(&net->xfrm.flow_cache_flush_work);
flush_work(&net->xfrm.flow_cache_gc_work);

I'm not sure if it is a bug or not. Could it happen that there is a
scheduled work while the kernel calls flow_cache_fini?

I originally suspected this was the real bug we hit, but we don't use
net namespaces, so our kernels never call flow_cache_fini.

> 
> Nice catch !
> 
> Ok, but you do not need to cc so many people/lists
> 
> netdev is fine, and we usually CC patch author, just in case.
> 
> Acked-by: Eric Dumazet <edumazet@google.com>
> 
