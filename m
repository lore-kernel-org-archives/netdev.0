From: Martin Kelly <martin@martingkelly.com>
Subject: Re: Question about synchronize_net() in AF_PACKET close()
Date: Wed, 17 Sep 2014 11:58:40 -0700
Message-ID: <CAN8CM3xyO3cgodRdj6LO5nUZ1rhcmio8eH6y8FZgG5CN5J3_6g@mail.gmail.com>
References: <CAN8CM3zo3bMxZV_UvywCPNjJrMwMA2-+POfY8cR429iodHRc+A@mail.gmail.com>
	<20140909.150000.1647602729214485795.davem@davemloft.net>
	<CAN8CM3xEnQXVgrLpV0rfAJoZ75v6Xv64pAGJ-9SAPACAT8WJ_w@mail.gmail.com>
	<54199AC7.1040502@martingkelly.com>
	<1410965690.7106.233.camel@edumazet-glaptop2.roam.corp.google.com>
	<CAN8CM3wpZ236h3Okfi0AS+9+0P05fd1JVwfUOXfbp_LV2PqLLQ@mail.gmail.com>
	<1410976371.7106.243.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Paul McKenney <paulmck@linux.vnet.ibm.com>,
	Stephen Hemminger <stephen@networkplumber.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f175.google.com ([209.85.212.175]:56437 "EHLO
	mail-wi0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755786AbaIQS6m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Sep 2014 14:58:42 -0400
Received: by mail-wi0-f175.google.com with SMTP id r20so848114wiv.2
        for <netdev@vger.kernel.org>; Wed, 17 Sep 2014 11:58:41 -0700 (PDT)
In-Reply-To: <1410976371.7106.243.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 17, 2014 at 10:52 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>
> I have a plan to remove the nulls support for UDP stack, because we
> would like to be able to use million of connected UDP sockets, and we
> would like to get rid of the atomic_inc()/atomic_dec() on socket
> refcount for every incoming message ;)
>
> My plan was to add a way for a socket to be freed after one rcu grace
> period.
>
> It would be an opt-in for protocols needing this. TCP stack would
> continue to use SLAB_DESTROY_BY_RCU.
>
> af_packet could immediately use this, and not have to use
> synchronize_net() at all.
>
That sounds like a great idea. Do you have a rough estimate of how
long that work will take or what will be required?
