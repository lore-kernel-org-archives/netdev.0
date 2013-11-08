From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v4 net-next] net: introduce dev_set_forwarding()
Date: Thu, 07 Nov 2013 20:40:00 -0800
Message-ID: <1383885600.9412.187.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1383584130.1553.2.camel@bwh-desktop.uk.level5networks.com>
	 <20131107.161755.355597965034457889.davem@davemloft.net>
	 <20131107213111.GA6885@gondor.apana.org.au>
	 <20131107.170651.1819930710384730745.davem@davemloft.net>
	 <20131108021758.GA13467@gondor.apana.org.au>
	 <1383878554.9412.153.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1383879113.9412.155.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20131108032359.GA14132@gondor.apana.org.au>
	 <1383884517.9412.172.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20131108042425.GA14577@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, bhutchings@solarflare.com,
	christoph.paasch@uclouvain.be, netdev@vger.kernel.org,
	hkchu@google.com, mwdalton@google.com
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f169.google.com ([209.85.192.169]:54820 "EHLO
	mail-pd0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751535Ab3KHEkC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Nov 2013 23:40:02 -0500
Received: by mail-pd0-f169.google.com with SMTP id q10so1608308pdj.0
        for <netdev@vger.kernel.org>; Thu, 07 Nov 2013 20:40:01 -0800 (PST)
In-Reply-To: <20131108042425.GA14577@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-11-08 at 12:24 +0800, Herbert Xu wrote:

> I don't know why you're fixing this problem by disabling/degrading
> GRO instead of fixing the qdisc to intelligently segment the GRO
> packet.

On what criteria you decide that the packet you are going to queue to
the NIC must be segmented ?

How do you predict the future ?

BTW, the Qdisc API doesnt really permit what you describe.

There are the queue() and dequeue(). Once packet is dequeued, you cannot
requeue a bunch of packets if you decide to segment the GRO packet.

This would require a lot of changes, while its much easier to give a
limit to GRO layer (replace the 65536 constant in skb_gro_receive() to
dev->max_gro_size).

Its rare the same host is used both as a latency sensitive router, and a
virt box...
