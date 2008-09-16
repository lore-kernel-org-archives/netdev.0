From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH take 2] pkt_sched: Fix qdisc_watchdog() vs.
	dev_deactivate() race
Date: Tue, 16 Sep 2008 10:47:56 +0000
Message-ID: <20080916104756.GA10965@ff.dom.local>
References: <20080913205408.GA2545@ami.dom.local> <20080914061610.GA20571@gondor.apana.org.au> <5f2db9d90809140331k434b9944mf5edf16e3094f12c@mail.gmail.com> <20080914214331.GB2540@ami.dom.local> <20080914221341.GA1684@gondor.apana.org.au> <20080915060758.GA4112@ff.dom.local> <20080915061922.GA7262@gondor.apana.org.au> <20080915072008.GB4112@ff.dom.local> <20080915074536.GD4112@ff.dom.local> <80769D7B14936844A23C0C43D9FBCF0F157D357E@orsmsx501.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Alexander Duyck <alexander.duyck@gmail.com>,
	David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"kaber@trash.net" <kaber@trash.net>
To: "Duyck, Alexander H" <alexander.h.duyck@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.173]:63943 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752309AbYIPKsG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Sep 2008 06:48:06 -0400
Received: by ug-out-1314.google.com with SMTP id k3so52444ugf.37
        for <netdev@vger.kernel.org>; Tue, 16 Sep 2008 03:48:03 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <80769D7B14936844A23C0C43D9FBCF0F157D357E@orsmsx501.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 15, 2008 at 04:44:08PM -0700, Duyck, Alexander H wrote:
...
> The only thing I really prefer about my solution as opposed to the solution
> Dave implemented was that it would mean only one dequeue instead of a peek
> followed by a dequeue.  I figure the important thing is to push the
> discovery of us being stopped to as soon as possible in the process.
> 
> It will probably be a few days before I have a patch with my approach ready.
> I didn't realize how complex it would be to resolve this issue for CBQ, HTB,
> HFSC, etc.  Also it is starting to look like I will probably need to implement
> another function to support this since it seems like the dequeue operations
> would need to be split into a multiqueue safe version, and a standard version
> to support some workarounds like those found in qdisc_peek_len() for HFSC.

Actually, looking at this HFSC now I start to doubt we need to
complicate these things so much. If HFSC is OK with its simple
hfsc_requeue() I doubt other qdiscs need much more, and we should
reconsider David's idea to do the same on top, in dev_requeue_skb().
Qdiscs like multiq would probably never use this, and these above
mentioned (not mq-optimized) qdiscs could be used with multiq if
needed. Then, it seems, it would be enough to improve multiq as a
"leaf" adding these dedicated operations and/or flags.

Thanks,
Jarek P.
