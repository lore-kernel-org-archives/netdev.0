From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH 1/2] netpoll: Remove dead netpoll_rx code
Date: Thu, 13 Mar 2014 15:23:11 -0400 (EDT)
Message-ID: <20140313.152311.1995854418463980325.davem@davemloft.net>
References: <1394540961.21721.22.camel@edumazet-glaptop2.roam.corp.google.com>
	<20140311082312.5ad00119@nehalam.linuxnetplumber.net>
	<87eh28cvi6.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: stephen@networkplumber.org, eric.dumazet@gmail.com,
	netdev@vger.kernel.org, xiyou.wangcong@gmail.com, mpm@selenic.com,
	satyam.sharma@gmail.com
To: ebiederm@xmission.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55357 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754751AbaCMTXO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Mar 2014 15:23:14 -0400
In-Reply-To: <87eh28cvi6.fsf@xmission.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: ebiederm@xmission.com (Eric W. Biederman)
Date: Tue, 11 Mar 2014 13:48:01 -0700

> To play devil's advocate to my own patch.  Does anyone know where kgdb
> over network (kgdboe) code lives today?
> 
> What little I could find in a quick google search strongly suggests that
> kgdboe was abandoned in 2010 or so.
> 
> I am trying to figure out if there are any active out of tree projects
> that need by directional netpoll.

Good questions.

I, perhaps mistakenly, kept the functionality around because there
were claims that we'd use it in-tree.

That of course never materialized.

The fact that people have a lot of trouble even finding the kgdboe
sources is quite telling, indeed.

Let's kill it, we can pull it back in (perhaps with a better design)
if something is proposed in-tree that will need it.

But I'm skeptical we ever will need it, and even if such a
reinstatement is proposed f.e. for the kgdboe use case it has holes.

Consider the case where kgdboe takes a breakpoint in a hardware
interrupt handler.  What happens?  We cannot allow it to perform a
full back-and-forth conversation with the remote gdb from such a
context.
