From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/3] pkt_sched: restore multiqueue prio scheduler
Date: Sat, 23 Aug 2008 01:23:42 -0700 (PDT)
Message-ID: <20080823.012342.72227414.davem@davemloft.net>
References: <5f2db9d90808221837h2f727478qf78bb6e6a2867802@mail.gmail.com>
	<E1KWlQH-0001Ge-00@gondolin.me.apana.org.au>
	<5f2db9d90808222335p223f1577l41841fb37490d85a@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, jarkao2@gmail.com, hadi@cyberus.ca,
	jeffrey.t.kirsher@intel.com, jeff@garzik.org,
	netdev@vger.kernel.org, alexander.h.duyck@intel.com
To: alexander.duyck@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42835
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750865AbYHWIXn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Aug 2008 04:23:43 -0400
In-Reply-To: <5f2db9d90808222335p223f1577l41841fb37490d85a@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Alexander Duyck" <alexander.duyck@gmail.com>
Date: Fri, 22 Aug 2008 23:35:24 -0700

> It isn't the performance aspect of running everything through one
> queue that I am concerned about since that is how it was working
> before.  My concern is that the action could cause a dead lock if
> simple_tx_hash places traffic on 2 queues and then the tc rule tried
> to swap the traffic between those queues while they are each holding
> their own queue locks.

You really should look at how the current code works before
coming to conclusions like this ;-)

When you configure any qdisc onto a device using tc, you get a single
qdisc which is shared by all of the TXQ objects of the device.

The per-TXQ qdisc thing only happens for the default qdisc.
