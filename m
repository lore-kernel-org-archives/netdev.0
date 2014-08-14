From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net] tcp: don't allow syn packets without timestamps to
 pass tcp_tw_recycle logic
Date: Thu, 14 Aug 2014 20:39:23 +0200
Message-ID: <1408041563.25187.1.camel@localhost>
References: <69ff43477a795a1117302b11583bc8ea8c5dc811.1407802666.git.hannes@stressinduktion.org>
	 <20140811.200807.1174604291924802129.davem@davemloft.net>
	 <1407830922.3313272.151751729.150ABE1E@webmail.messagingengine.com>
	 <1408009065.2751.6.camel@localhost>
	 <1408030715.6804.21.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	fw@strlen.de
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [66.111.4.27] ([66.111.4.27]:59032 "EHLO
	out3-smtp.messagingengine.com" rhost-flags-FAIL-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752879AbaHNSkB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Aug 2014 14:40:01 -0400
Received: from compute2.internal (compute2.nyi.internal [10.202.2.42])
	by gateway1.nyi.internal (Postfix) with ESMTP id 9D6982342C
	for <netdev@vger.kernel.org>; Thu, 14 Aug 2014 14:39:25 -0400 (EDT)
In-Reply-To: <1408030715.6804.21.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Do, 2014-08-14 at 08:38 -0700, Eric Dumazet wrote:
> On Thu, 2014-08-14 at 11:37 +0200, Hannes Frederic Sowa wrote:
> 
> > did you have a chance to look at this patch again?
> > 
> > I found this during code review. Non time stamped SYN packets could
> > eventually trigger the completion of a 3WHS even though we had
> > tw_recycle enabled and the SYN arrived in a TCP_PAWS_MSL of this host
> > period.
> 
> 
> > 
> > I don't want to make this feature more general usable (without time
> > stamps), they are absolutely required. It just adds protection against
> > accidental 3WHS completion of 3WHS if a packet without time stamps
> > arrived.
> > 
> > I don't have a strong opinion on that but it just seems to be natural,
> > as we also conditional schedule the timeout for the tw buckets depending
> > on if we saw time stamps on the prior connection.
> 
> I believe this patch gives a wrong sense of comfort, and honestly this
> is caused by its changelog.
> 
> Sane people should not use tw_recycle, and eventually we should remove
> its support.
> 
> Your changelog is misleading because it could give bad incentive about
> _using_ tw_recycle.
> 
> Please rephrase it so that no doubt is possible.

Yep, I also thought the changelog might be too poor after your response.
Will resend soon with updated changelog.

Thanks,
Hannes
