From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net 4/4] tcp: various missing rcu_read_lock around
 __sk_dst_get
Date: Fri, 01 Apr 2016 05:31:25 +0200
Message-ID: <1459481485.3777651.565382010.1CCB2A5E@webmail.messagingengine.com>
References: <1459466982-20432-1-git-send-email-hannes@stressinduktion.org>
 <1459466982-20432-5-git-send-email-hannes@stressinduktion.org>
 <1459467595.6473.233.camel@edumazet-glaptop3.roam.corp.google.com>
 <56FDBA6E.5030508@stressinduktion.org>
 <1459469572.6473.239.camel@edumazet-glaptop3.roam.corp.google.com>
 <56FDBF0E.8020309@stressinduktion.org>
 <1459473592.6473.243.camel@edumazet-glaptop3.roam.corp.google.com>
 <1459474618.3751123.565321858.30DF1858@webmail.messagingengine.com>
 <1459474756.6473.248.camel@edumazet-glaptop3.roam.corp.google.com>
 <1459475124.6473.250.camel@edumazet-glaptop3.roam.corp.google.com>
 <56FDD67E.2040904@stressinduktion.org>
 <1459480383.6473.270.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	sasha.levin@oracle.com, daniel@iogearbox.net,
	alexei.starovoitov@gmail.com, mkubecek@suse.cz
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out5-smtp.messagingengine.com ([66.111.4.29]:60044 "EHLO
	out5-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758325AbcDADb1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Mar 2016 23:31:27 -0400
Received: from compute5.internal (compute5.nyi.internal [10.202.2.45])
	by mailout.nyi.internal (Postfix) with ESMTP id 2D06820B9C
	for <netdev@vger.kernel.org>; Thu, 31 Mar 2016 23:31:26 -0400 (EDT)
In-Reply-To: <1459480383.6473.270.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On Fri, Apr 1, 2016, at 05:13, Eric Dumazet wrote:
> On Fri, 2016-04-01 at 04:01 +0200, Hannes Frederic Sowa wrote:
> 
> > I thought so first, as well. But given the double check for the 
> > spin_lock and the "mutex" we end up with the same result for the 
> > lockdep_sock_is_held check.
> > 
> > Do you see other consequences?
> 
> Well, we release the spinlock in __release_sock()
> 
> So another thread could come and acquire the socket, then call
> mutex_acquire() while the first thread did not call yet mutex_release()
> 
> So maybe lockdep will complain (but I do not know lockdep enough to
> tell)
> 
> So maybe the following would be better :
> 
> (Absolutely untested, really I need to take a break)

I quickly tested the patch and my scripts didn't show any splats so far.
This patch seems more consistent albeit I don't think it is relevant for
lockdep_sock_is_held as we only flip owned while holding slock. But this
definitely needs more review.

Thanks a lot!
