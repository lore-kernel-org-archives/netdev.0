From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH take 2] pkt_sched: Fix qdisc_watchdog() vs.
	dev_deactivate() race
Date: Mon, 15 Sep 2008 06:07:58 +0000
Message-ID: <20080915060758.GA4112@ff.dom.local>
References: <20080913011018.GA10242@gondor.apana.org.au> <20080912.182259.238925690.davem@davemloft.net> <20080913012758.GA10459@gondor.apana.org.au> <20080912.184008.74354363.davem@davemloft.net> <20080913014800.GA10611@gondor.apana.org.au> <20080913205408.GA2545@ami.dom.local> <20080914061610.GA20571@gondor.apana.org.au> <5f2db9d90809140331k434b9944mf5edf16e3094f12c@mail.gmail.com> <20080914214331.GB2540@ami.dom.local> <20080914221341.GA1684@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alexander Duyck <alexander.duyck@gmail.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	kaber@trash.net
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mu-out-0910.google.com ([209.85.134.188]:44090 "EHLO
	mu-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750721AbYIOGIE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Sep 2008 02:08:04 -0400
Received: by mu-out-0910.google.com with SMTP id g7so1484911muf.1
        for <netdev@vger.kernel.org>; Sun, 14 Sep 2008 23:08:02 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20080914221341.GA1684@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Sep 14, 2008 at 03:13:41PM -0700, Herbert Xu wrote:
> On Sun, Sep 14, 2008 at 11:43:31PM +0200, Jarek Poplawski wrote:
> >
> > On the other hand, I wondered about a possibility of rehashing to other
> > queues in some cases during requeuing, which would be impossible after
> > such change.
> 
> Why would you want to do that? Just because people have abused
> requeue in the psat doesn't mean that we need to support such
> abuses for perpetuity.

Well, it was only wondering, and probably you are right this is wrong.
On the other hand, simple_tx_hash() choices are "probabilistic": user
doesn't care if it goes through tx_queue #1 or #11. And here, in some
cases, some tx_queues could be always full while other always empty,
so some dynamic rehashing could be thought of, but I understand it's
not trivial.
 
Cheers,
Jarek P.
