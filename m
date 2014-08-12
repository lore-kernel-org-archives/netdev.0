From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH stable 3.4 1/2] ipv4: move route garbage collector to work
 queue
Date: Wed, 13 Aug 2014 01:11:14 +0200
Message-ID: <1407885074.3535486.152056309.7BDE2766@webmail.messagingengine.com>
References: <1407869404.27163.5.camel@localhost>
 <1407875003.6804.0.camel@edumazet-glaptop2.roam.corp.google.com>
 <1407879692.16087.5.camel@localhost>
 <20140812.154255.2235928819945086905.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, mleitner@redhat.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>, hannes@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from out3-smtp.messagingengine.com ([66.111.4.27]:53228 "EHLO
	out3-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751265AbaHLXLS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Aug 2014 19:11:18 -0400
Received: from compute4.internal (compute4.nyi.internal [10.202.2.44])
	by gateway1.nyi.internal (Postfix) with ESMTP id F00C923267
	for <netdev@vger.kernel.org>; Tue, 12 Aug 2014 19:11:14 -0400 (EDT)
In-Reply-To: <20140812.154255.2235928819945086905.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 13, 2014, at 00:42, David Miller wrote:
> The second patch, on the other hand, needs some more thought.  It is
> changing behavior, in that cases that would have succeeded in the past
> will now potentially fail only because the neighbour cache limits were
> hit at an unlucky moment (when an async GC was going already).
> 
> If this happens from a software interrupt, we'll fail instantly
> because attempts starts at 0.

Hmhmhm, a truly valid concern.

> Just bite the bullet and put a spinlock around the GC operation.

We had a spinlock around the GC operation at first but still were
capable to cause softlockups, I don't remember if a complete lockup
happend.

> The async GCs are normal on a loaded machine, whereas the neighbour
> tables filling up is much less so.  I think having the neighbout
> overflow path synchronize with async GCs is therefore not going to be
> a real problem in practice.

Thanks for your comments, we look into it. Should be no problem to
conditional synchronize with the neighbour overflow path.

Thanks,
Hannes
