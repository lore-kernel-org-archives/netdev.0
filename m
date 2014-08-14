From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net] tcp: don't allow syn packets without timestamps to
 pass tcp_tw_recycle logic
Date: Thu, 14 Aug 2014 11:37:45 +0200
Message-ID: <1408009065.2751.6.camel@localhost>
References: <69ff43477a795a1117302b11583bc8ea8c5dc811.1407802666.git.hannes@stressinduktion.org>
	 <20140811.200807.1174604291924802129.davem@davemloft.net>
	 <1407830922.3313272.151751729.150ABE1E@webmail.messagingengine.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, fw@strlen.de
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out3-smtp.messagingengine.com ([66.111.4.27]:46479 "EHLO
	out3-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752068AbaHNJhr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Aug 2014 05:37:47 -0400
Received: from compute4.internal (compute4.nyi.internal [10.202.2.44])
	by gateway1.nyi.internal (Postfix) with ESMTP id 39B5F21FC7
	for <netdev@vger.kernel.org>; Thu, 14 Aug 2014 05:37:47 -0400 (EDT)
In-Reply-To: <1407830922.3313272.151751729.150ABE1E@webmail.messagingengine.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

On Di, 2014-08-12 at 10:08 +0200, Hannes Frederic Sowa wrote:
> 
> On Tue, Aug 12, 2014, at 05:08, David Miller wrote:
> > From: Hannes Frederic Sowa <hannes@stressinduktion.org>
> > Date: Tue, 12 Aug 2014 02:21:36 +0200
> > 
> > > Thus this broken situation could easily arise by a Linux and Windows
> > > box sharing one IP address and talking to a tcp_tw_recycle enabled
> > > server.
> > 
> > As Eric Dumazet mentioned, timewait recycling does not work if any
> > traffic goes through a NAT box.
> > 
> > So this situation of two boxes "sharing one IP address" fundamentally
> > makes timewait recycling unusable.
> 
> Exactly, I'll just throw away the SYN packet instead of opening a
> connection where we couldn't very if the preconditions for timewait
> recycling did not hold.

did you have a chance to look at this patch again?

I found this during code review. Non time stamped SYN packets could
eventually trigger the completion of a 3WHS even though we had
tw_recycle enabled and the SYN arrived in a TCP_PAWS_MSL of this host
period.

I don't want to make this feature more general usable (without time
stamps), they are absolutely required. It just adds protection against
accidental 3WHS completion of 3WHS if a packet without time stamps
arrived.

I don't have a strong opinion on that but it just seems to be natural,
as we also conditional schedule the timeout for the tw buckets depending
on if we saw time stamps on the prior connection.

Thanks,
Hannes
