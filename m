From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] [PATCH] Don't run __qdisc_run() on a stopped TX queue
Date: Mon, 27 Jul 2009 19:28:44 -0700 (PDT)
Message-ID: <20090727.192844.163233275.davem@davemloft.net>
References: <20090724083749.GA23521@gondor.apana.org.au>
	<OFFA0E0F2C.B17AF73A-ON652575FD.00372349-652575FD.0039CB03@in.ibm.com>
	<20090725032436.GA30741@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: krkumar2@in.ibm.com, jarkao2@gmail.com, netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48589
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752095AbZG1C2h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Jul 2009 22:28:37 -0400
In-Reply-To: <20090725032436.GA30741@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Sat, 25 Jul 2009 11:24:36 +0800

> Dave, remember our discussion about the benefits of using multiqueue
> TX just for the sake of enarlging the TX queues? How about just
> going back to using a single queue for non-default qdiscs (at
> least until such a time when non-default qdiscs start doing
> multiple queues internally)?
> 
> Yes it would mean potentially smaller queues for those non-default
> qdisc users, but they're usually the same people who want the
> hardware to queue as little as possible in order to enforce whatever
> it is that their qdisc is designed to enforce.

There is a locking benefit even for non-default qdiscs.

Instead of two choke points (qdisc lock and queue lock) there
is now only one (qdisc lock) and consdiering the cost of
things like setting up IOMMU mappings and hitting chip
registers the qdisc lock is the shortest held of the two.

So going to one queue would be a serious regression.
