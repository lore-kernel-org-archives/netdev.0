From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH stable 3.4 1/2] ipv4: move route garbage collector to work
 queue
Date: Wed, 13 Aug 2014 03:50:02 +0200
Message-ID: <1407894602.3568281.152093941.305B970A@webmail.messagingengine.com>
References: <1407879692.16087.5.camel@localhost>
 <20140812.154255.2235928819945086905.davem@davemloft.net>
 <1407885074.3535486.152056309.7BDE2766@webmail.messagingengine.com>
 <20140812.174621.1935425856781215649.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: hannes@redhat.com, eric.dumazet@gmail.com, mleitner@redhat.com,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out3-smtp.messagingengine.com ([66.111.4.27]:33862 "EHLO
	out3-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752567AbaHMBuF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Aug 2014 21:50:05 -0400
Received: from compute4.internal (compute4.nyi.internal [10.202.2.44])
	by gateway1.nyi.internal (Postfix) with ESMTP id D7DEC276DA
	for <netdev@vger.kernel.org>; Tue, 12 Aug 2014 21:50:02 -0400 (EDT)
In-Reply-To: <20140812.174621.1935425856781215649.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

On Wed, Aug 13, 2014, at 02:46, David Miller wrote:
> From: Hannes Frederic Sowa <hannes@stressinduktion.org>
> Date: Wed, 13 Aug 2014 01:11:14 +0200
> 
> > On Wed, Aug 13, 2014, at 00:42, David Miller wrote:
> >> Just bite the bullet and put a spinlock around the GC operation.
> > 
> > We had a spinlock around the GC operation at first but still were
> > capable to cause softlockups, I don't remember if a complete lockup
> > happend.
> 
> This much I understand.
> 
> What I'm saying is retain this patch #1, in order to make the normal
> GCs run asynchronously via a work queue, but on top of that put a
> spinlock around the GC function.

I understood you correctly. ;)

The spin_lock would need to be _bh protected as it can be called from
softirq as well as in the wq. IIRC that was the problem. I'll follow up
with Marcelo to find a solution for this.

Thanks,
Hannes
