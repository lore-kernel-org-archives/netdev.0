From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH take 2] pkt_sched: Fix qdisc_watchdog() vs.
	dev_deactivate() race
Date: Sun, 14 Sep 2008 23:19:22 -0700
Message-ID: <20080915061922.GA7262@gondor.apana.org.au>
References: <20080912.182259.238925690.davem@davemloft.net> <20080913012758.GA10459@gondor.apana.org.au> <20080912.184008.74354363.davem@davemloft.net> <20080913014800.GA10611@gondor.apana.org.au> <20080913205408.GA2545@ami.dom.local> <20080914061610.GA20571@gondor.apana.org.au> <5f2db9d90809140331k434b9944mf5edf16e3094f12c@mail.gmail.com> <20080914214331.GB2540@ami.dom.local> <20080914221341.GA1684@gondor.apana.org.au> <20080915060758.GA4112@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alexander Duyck <alexander.duyck@gmail.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	kaber@trash.net
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:44922 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751257AbYIOGTb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Sep 2008 02:19:31 -0400
Content-Disposition: inline
In-Reply-To: <20080915060758.GA4112@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 15, 2008 at 06:07:58AM +0000, Jarek Poplawski wrote:
>
> Well, it was only wondering, and probably you are right this is wrong.
> On the other hand, simple_tx_hash() choices are "probabilistic": user
> doesn't care if it goes through tx_queue #1 or #11. And here, in some
> cases, some tx_queues could be always full while other always empty,
> so some dynamic rehashing could be thought of, but I understand it's
> not trivial.

No that would be totally wrong.  One of the important constraints
on a TX hashing mechanism is to preserve packet ordering within
a flow.  If simple_tx_hash started placing the same packet in
different queues then it would do the same thing to flows which
is unacceptable.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
