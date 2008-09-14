From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH take 2] pkt_sched: Fix qdisc_watchdog() vs.
	dev_deactivate() race
Date: Sun, 14 Sep 2008 23:43:31 +0200
Message-ID: <20080914214331.GB2540@ami.dom.local>
References: <20080913011018.GA10242@gondor.apana.org.au> <20080912.182259.238925690.davem@davemloft.net> <20080913012758.GA10459@gondor.apana.org.au> <20080912.184008.74354363.davem@davemloft.net> <20080913014800.GA10611@gondor.apana.org.au> <20080913205408.GA2545@ami.dom.local> <20080914061610.GA20571@gondor.apana.org.au> <5f2db9d90809140331k434b9944mf5edf16e3094f12c@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	kaber@trash.net
To: Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gx0-f16.google.com ([209.85.217.16]:51868 "EHLO
	mail-gx0-f16.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753393AbYINVmI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 14 Sep 2008 17:42:08 -0400
Received: by gxk9 with SMTP id 9so23192550gxk.13
        for <netdev@vger.kernel.org>; Sun, 14 Sep 2008 14:42:06 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <5f2db9d90809140331k434b9944mf5edf16e3094f12c@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Sep 14, 2008 at 03:31:35AM -0700, Alexander Duyck wrote:
...
> What if we were to push the check for netif_tx_queue_stopped further down into
> the qdisc layer so that the basic qdiscs such as pfifo_fast did their own peek
> and in the event that a queue is stopped it just returned NULL and set a flag
> bit?  Basically this would mimic how we are currently handling throttled
> queues (TCQ_F_THROTTLED).  Then in turn each parent could do a check on skb ==
> NULL and set the same flag, or they could act like multiq and just skip over
> that leaf and move onto the next because it is stopped.

IMHO it's a very interesting idea. Probably it could be better
evaluated if we have any stats how much this reason of requeing is a
problem with mq devices.

On the other hand, I wondered about a possibility of rehashing to other
queues in some cases during requeuing, which would be impossible after
such change.

Thanks,
Jarek P.
