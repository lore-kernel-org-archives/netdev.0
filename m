From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH take 2] pkt_sched: Fix qdisc_watchdog() vs.
	dev_deactivate() race
Date: Sun, 14 Sep 2008 07:56:58 -0400
Message-ID: <1221393419.4675.66.camel@localhost>
References: <20080913011018.GA10242@gondor.apana.org.au>
	 <20080912.182259.238925690.davem@davemloft.net>
	 <20080913012758.GA10459@gondor.apana.org.au>
	 <20080912.184008.74354363.davem@davemloft.net>
	 <20080913014800.GA10611@gondor.apana.org.au>
	 <20080913205408.GA2545@ami.dom.local>
	 <20080914061610.GA20571@gondor.apana.org.au>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Jarek Poplawski <jarkao2@gmail.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	kaber@trash.net
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.239]:51634 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752876AbYINL5F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 14 Sep 2008 07:57:05 -0400
Received: by rv-out-0506.google.com with SMTP id k40so1682923rvb.1
        for <netdev@vger.kernel.org>; Sun, 14 Sep 2008 04:57:03 -0700 (PDT)
In-Reply-To: <20080914061610.GA20571@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2008-13-09 at 23:16 -0700, Herbert Xu wrote:
> In any case, do you have an alternative solution to the
> current problem that qdisc_run looks at an arbitrary queue's
> status to decide whether it should process a qdisc that empties
> into n queues?

What about something that would be cheaper than a peek - just check some
driver per-hwq variable? variable is set at netif_stop and unset at
netif_wake and should tell you if the driver infact can send if you gave
it a packet (way before you dequeue from qdisc, assuming you know which
hardware queue it is going to).

cheers,
jamal

