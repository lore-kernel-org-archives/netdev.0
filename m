From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 3/3] pkt_sched: restore multiqueue prio scheduler
Date: Sat, 23 Aug 2008 17:07:11 +1000
Message-ID: <E1KWnDL-0001RH-00@gondolin.me.apana.org.au>
References: <5f2db9d90808222335p223f1577l41841fb37490d85a@mail.gmail.com>
Cc: herbert@gondor.apana.org.au, davem@davemloft.net,
	jarkao2@gmail.com, hadi@cyberus.ca, jeffrey.t.kirsher@intel.com,
	jeff@garzik.org, netdev@vger.kernel.org,
	alexander.h.duyck@intel.com
To: alexander.duyck@gmail.com (Alexander Duyck)
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:34859 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751652AbYHWHHY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Aug 2008 03:07:24 -0400
In-Reply-To: <5f2db9d90808222335p223f1577l41841fb37490d85a@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Alexander Duyck <alexander.duyck@gmail.com> wrote:
> 
> It isn't the performance aspect of running everything through one
> queue that I am concerned about since that is how it was working
> before.  My concern is that the action could cause a dead lock if
> simple_tx_hash places traffic on 2 queues and then the tc rule tried
> to swap the traffic between those queues while they are each holding
> their own queue locks.  The tc rule would have to receive all traffic
> onto a single qdisc to prevent this, which would require setting
> select_queue for the netdev to return a fixed queue.  The multiqueue
> prio qdisc is flexible enough to allow all traffic to be directed to
> one queue or be received on multiple queues without causing the system
> to lock up which means that implementing select_queue on the device
> wouldn't be mandatory.

As it is if you create a custom qdisc then there will only be
a single qdisc no matter how many hardware queues you have.  So
you can safely dequeue from the qdisc into any hardware queue you
want.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
