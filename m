From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2 net-next] tcp: set SOCK_NOSPACE under memory pressure
Date: Fri, 15 May 2015 07:50:23 -0700
Message-ID: <1431701423.27831.101.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20150506155223.9743A2027@prod-mail-relay06.akamai.com>
	 <20150509.173859.948723291650094235.davem@davemloft.net>
	 <1431659228.27831.89.camel@edumazet-glaptop2.roam.corp.google.com>
	 <555600B6.4040400@akamai.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Jason Baron <jbaron@akamai.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f182.google.com ([209.85.213.182]:35191 "EHLO
	mail-ig0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752854AbbEOOuZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 May 2015 10:50:25 -0400
Received: by igbyr2 with SMTP id yr2so222987111igb.0
        for <netdev@vger.kernel.org>; Fri, 15 May 2015 07:50:25 -0700 (PDT)
In-Reply-To: <555600B6.4040400@akamai.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2015-05-15 at 10:20 -0400, Jason Baron wrote:
> On 05/14/2015 11:07 PM, Eric Dumazet wrote:
> > On Sat, 2015-05-09 at 17:38 -0400, David Miller wrote:
> >> Applied, thanks a lot for adding so much information to the commit
> >> message.
> >> --
> > When doing more tests with this stuff, I found we could still have
> > hangs, because a TCP socket can end up having no skb in its write queue.
> >
> > We need to allow one skb (this can be 2KB) to keep the logic being ACK
> > driven.
> >
> 
> Indeed. I alluded to that in the commit message.
> 
> The 2KB minimum wouldn't help in the case where we really got
> -ENOMEM from the core allocator, unless I guess we reserved
> the 2KB permanently. Or we could just issue the wakeup in the
> case where we return -EAGAIN and the write queue is empty.
> That is a very simple additional change here, I think.

I cooked a patch series, will send it very soon.

The ENOMEM in core allocator is very unlikely, as we use GFP_KERNEL.

Normally, memcg and/or tcp_mem[] should prevent this from happening.
