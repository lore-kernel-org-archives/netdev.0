From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH take 2] pkt_sched: Fix qdisc_watchdog() vs.
	dev_deactivate() race
Date: Mon, 15 Sep 2008 07:20:08 +0000
Message-ID: <20080915072008.GB4112@ff.dom.local>
References: <20080913012758.GA10459@gondor.apana.org.au> <20080912.184008.74354363.davem@davemloft.net> <20080913014800.GA10611@gondor.apana.org.au> <20080913205408.GA2545@ami.dom.local> <20080914061610.GA20571@gondor.apana.org.au> <5f2db9d90809140331k434b9944mf5edf16e3094f12c@mail.gmail.com> <20080914214331.GB2540@ami.dom.local> <20080914221341.GA1684@gondor.apana.org.au> <20080915060758.GA4112@ff.dom.local> <20080915061922.GA7262@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alexander Duyck <alexander.duyck@gmail.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	kaber@trash.net
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gx0-f16.google.com ([209.85.217.16]:38836 "EHLO
	mail-gx0-f16.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752303AbYIOHUO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Sep 2008 03:20:14 -0400
Received: by gxk9 with SMTP id 9so24171648gxk.13
        for <netdev@vger.kernel.org>; Mon, 15 Sep 2008 00:20:13 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20080915061922.GA7262@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Sep 14, 2008 at 11:19:22PM -0700, Herbert Xu wrote:
> On Mon, Sep 15, 2008 at 06:07:58AM +0000, Jarek Poplawski wrote:
> >
> > Well, it was only wondering, and probably you are right this is wrong.
> > On the other hand, simple_tx_hash() choices are "probabilistic": user
> > doesn't care if it goes through tx_queue #1 or #11. And here, in some
> > cases, some tx_queues could be always full while other always empty,
> > so some dynamic rehashing could be thought of, but I understand it's
> > not trivial.
> 
> No that would be totally wrong.  One of the important constraints
> on a TX hashing mechanism is to preserve packet ordering within
> a flow.  If simple_tx_hash started placing the same packet in
> different queues then it would do the same thing to flows which
> is unacceptable.

Of course preserving a flow consistency is must-be here, but I think
there are rehashing algorithms used in similar cases (sch_sfq) which
take care for this. As a matter of fact, I've thought of requeuing as
a best place to detect possible problems, but now I see that
Alexander's proposal let's to do this simply by observing this
TCQ_F_STOPPED flag, so I withdraw my objection.

Cheers,
Jarek P.
