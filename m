From: Balazs Scheidler <bazsi@balabit.hu>
Subject: Re: [RFC][PATCH] [TPROXY] kick out TIME_WAIT sockets in case a new
 connection comes in with the same tuple
Date: Wed, 10 Dec 2008 09:52:22 +0100
Message-ID: <1228899142.7542.31.camel@bzorp.balabit>
References: <1228812695.7631.16.camel@bzorp.balabit>
	 <20081209.221838.206534714.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tproxy@lists.balabit.hu, hidden@sch.bme.hu,
	panther@balabit.hu
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from support.balabit.hu ([195.70.41.86]:40519 "EHLO lists.balabit.hu"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751489AbYLJIw2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Dec 2008 03:52:28 -0500
Received: from balabit.hu (unknown [10.80.0.254])
	by lists.balabit.hu (Postfix) with ESMTP id 81F8939D3F6
	for <netdev@vger.kernel.org>; Wed, 10 Dec 2008 09:52:26 +0100 (CET)
In-Reply-To: <20081209.221838.206534714.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2008-12-09 at 22:18 -0800, David Miller wrote:
> From: Balazs Scheidler <bazsi@balabit.hu>
> Date: Tue, 09 Dec 2008 08:51:35 +0000
> 
> > Hi,
> > 
> > I'd like to get some guidance regarding the following patch. There's a 
> > severe performance limitation related to TIME_WAIT sockets and TProxy rules.
> > The patch below is the 'nice' approach, but it adds 6 bytes to 
> > inet_sock and inet_timewait_sock. The 'ugly' approach would be to schedule the
> > removal of the affected TIME_WAIT sockets at PREROUTING time.
> > 
> > This post is meant to get some review, but please do not apply this patch this time.
> 
> I have no general objection to this, but people seem to be
> experts at making various parts of the TCP socket structures
> larger and larger :-(
> 

I understand. Here are the alternatives I considered:
 1) the patch above, by extending the socket structures
 2) expand skb, of course I felt this is worse than the patch I posted
 3) call inet_twsk_deschedule() from the prerouting hook

The 3rd one does not require any expansion of the related structures,
however it'd mean that the TCP state is not only looked up, but also
changed from the TPROXY target. I felt this ugly, but the ugliness would
be constrained to the tproxy code. Shall I post a patch implementing
option #3 above?

-- 
Bazsi


