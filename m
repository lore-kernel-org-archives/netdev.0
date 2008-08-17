From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] pkt_sched: Destroy gen estimators under rtnl_lock().
Date: Sun, 17 Aug 2008 14:34:44 -0700 (PDT)
Message-ID: <20080817.143444.252525600.davem@davemloft.net>
References: <20080813.151918.61294677.davem@davemloft.net>
	<20080814112433.GA12476@ff.dom.local>
	<48A82ADE.5010903@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org,
	denys@visp.net.lb
To: jarkao2@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37628
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751663AbYHQVeo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 Aug 2008 17:34:44 -0400
In-Reply-To: <48A82ADE.5010903@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jarek Poplawski <jarkao2@gmail.com>
Date: Sun, 17 Aug 2008 15:42:54 +0200

> Jarek Poplawski wrote, On 08/14/2008 01:24 PM:
> 
> > On Wed, Aug 13, 2008 at 03:19:18PM -0700, David Miller wrote:
> > ...
> >> Ok, so what I'm going to do is check in my patch and then try
> >> to figure out how to resolve this "both bits clear" scenerio.
> > 
> > BTW, here is my older doubt revisited, where I hope to be re-considered/
> > re-convinced, if possible...
> 
> 
> After problems while testing this by Denys in another thread
> I withdraw this patch.

Well, I knew it was completely wrong from the beginning, sorry
to say :-)

This stuff can't be done outside of RCU, period.  I moved all of this
work into RCU for a reason, I really meant it, and none of the reasons
for that move have changed :-)

If we want to do it under RTNL we have to do something like schedule a
workqueue from the RCU handler and then take the RTNL there.
