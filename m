From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] tcp: don't allow syn packets without timestamps to
 pass tcp_tw_recycle logic
Date: Thu, 14 Aug 2014 08:38:35 -0700
Message-ID: <1408030715.6804.21.camel@edumazet-glaptop2.roam.corp.google.com>
References: <69ff43477a795a1117302b11583bc8ea8c5dc811.1407802666.git.hannes@stressinduktion.org>
	 <20140811.200807.1174604291924802129.davem@davemloft.net>
	 <1407830922.3313272.151751729.150ABE1E@webmail.messagingengine.com>
	 <1408009065.2751.6.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	fw@strlen.de
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f180.google.com ([209.85.192.180]:49997 "EHLO
	mail-pd0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755104AbaHNPij (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Aug 2014 11:38:39 -0400
Received: by mail-pd0-f180.google.com with SMTP id v10so1766863pde.39
        for <netdev@vger.kernel.org>; Thu, 14 Aug 2014 08:38:38 -0700 (PDT)
In-Reply-To: <1408009065.2751.6.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2014-08-14 at 11:37 +0200, Hannes Frederic Sowa wrote:

> did you have a chance to look at this patch again?
> 
> I found this during code review. Non time stamped SYN packets could
> eventually trigger the completion of a 3WHS even though we had
> tw_recycle enabled and the SYN arrived in a TCP_PAWS_MSL of this host
> period.


> 
> I don't want to make this feature more general usable (without time
> stamps), they are absolutely required. It just adds protection against
> accidental 3WHS completion of 3WHS if a packet without time stamps
> arrived.
> 
> I don't have a strong opinion on that but it just seems to be natural,
> as we also conditional schedule the timeout for the tw buckets depending
> on if we saw time stamps on the prior connection.

I believe this patch gives a wrong sense of comfort, and honestly this
is caused by its changelog.

Sane people should not use tw_recycle, and eventually we should remove
its support.

Your changelog is misleading because it could give bad incentive about
_using_ tw_recycle.

Please rephrase it so that no doubt is possible.

Thanks
