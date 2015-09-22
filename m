From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH v2] netlink: Replace rhash_portid with bound
Date: Tue, 22 Sep 2015 14:53:57 -0400
Message-ID: <20150922185357.GD17659@mtj.duckdns.org>
References: <20150918111650.GA7508@gondor.apana.org.au>
 <20150920.225521.1063980101511317898.davem@davemloft.net>
 <20150921060636.GA30807@gondor.apana.org.au>
 <20150920.231104.525285577747035896.davem@davemloft.net>
 <20150921133415.GA1740@gondor.apana.org.au>
 <20150921182022.GB13263@mtj.duckdns.org>
 <20150922033856.GA7851@gondor.apana.org.au>
 <20150922161056.GB9761@mtj.duckdns.org>
 <CA+55aFyvPLD5tNsuxFAA4GgOZpamULJe7R90dXf5qSC6aBYzTw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	David Miller <davem@davemloft.net>,
	Cong Wang <cwang@twopensource.com>, tom@herbertland.com,
	kafai@fb.com, kernel-team@fb.com,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	=?utf-8?B?SmnFmcOtIFDDrXJrbw==?= <jiri@resnulli.us>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	Thomas Graf <tgraf@suug.ch>, Scott Feldman <sfeldma@gmail.com>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f182.google.com ([209.85.160.182]:34187 "EHLO
	mail-yk0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759091AbbIVSyD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Sep 2015 14:54:03 -0400
Content-Disposition: inline
In-Reply-To: <CA+55aFyvPLD5tNsuxFAA4GgOZpamULJe7R90dXf5qSC6aBYzTw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello, Linus.

On Tue, Sep 22, 2015 at 11:42:33AM -0700, Linus Torvalds wrote:
...
> smp_rmb() should generally be about the same cost as an acquire. It
> can go either way.
> 
> So *if* the algorithm is amenable to smp_wmb()/smp_rmb() kind of
> barriers, that's actually quite possibly better than acquire/release.

I see.  The write path here is cold so the competition is between rmb
and acquire.  Unless some significant archs completely screwed it up,
acquire still seems like the better option.  It's essentially free on
x86 after all.

Thanks.

-- 
tejun
