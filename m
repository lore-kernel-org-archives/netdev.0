From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH take 2] pkt_sched: Fix qdisc_watchdog() vs.
	dev_deactivate() race
Date: Mon, 15 Sep 2008 07:45:36 +0000
Message-ID: <20080915074536.GD4112@ff.dom.local>
References: <20080912.184008.74354363.davem@davemloft.net> <20080913014800.GA10611@gondor.apana.org.au> <20080913205408.GA2545@ami.dom.local> <20080914061610.GA20571@gondor.apana.org.au> <5f2db9d90809140331k434b9944mf5edf16e3094f12c@mail.gmail.com> <20080914214331.GB2540@ami.dom.local> <20080914221341.GA1684@gondor.apana.org.au> <20080915060758.GA4112@ff.dom.local> <20080915061922.GA7262@gondor.apana.org.au> <20080915072008.GB4112@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alexander Duyck <alexander.duyck@gmail.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	kaber@trash.net
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.159]:4894 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752112AbYIOHpn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Sep 2008 03:45:43 -0400
Received: by fg-out-1718.google.com with SMTP id 19so1300766fgg.17
        for <netdev@vger.kernel.org>; Mon, 15 Sep 2008 00:45:41 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20080915072008.GB4112@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 15, 2008 at 07:20:08AM +0000, Jarek Poplawski wrote:
...
> Of course preserving a flow consistency is must-be here, but I think
> there are rehashing algorithms used in similar cases (sch_sfq) which
> take care for this. As a matter of fact, I've thought of requeuing as
> a best place to detect possible problems, but now I see that
> Alexander's proposal let's to do this simply by observing this
> TCQ_F_STOPPED flag [...]

Hmm... or maybe it doesn't? Since this is qdisc flag we don't know at
the top which tx_queue is a problem at the bottom...

Jarek P.
