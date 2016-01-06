From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: sched: fix missing free per cpu on qstats
Date: Tue, 05 Jan 2016 19:07:49 -0800
Message-ID: <1452049669.8255.157.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20160105171136.9063.98710.stgit@john-Precision-Tower-5810>
	 <1452015851.8255.108.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CAM_iQpW9qCOuFGAKDY0e=qsT_PY-CdU3FyNK0tA2cRVkxAwAZw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: John Fastabend <john.fastabend@gmail.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Daniel Borkmann <daniel@iogearbox.net>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:34289 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751137AbcAFDHv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jan 2016 22:07:51 -0500
Received: by mail-pa0-f48.google.com with SMTP id uo6so206416700pac.1
        for <netdev@vger.kernel.org>; Tue, 05 Jan 2016 19:07:50 -0800 (PST)
In-Reply-To: <CAM_iQpW9qCOuFGAKDY0e=qsT_PY-CdU3FyNK0tA2cRVkxAwAZw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2016-01-05 at 18:49 -0800, Cong Wang wrote:
> On Tue, Jan 5, 2016 at 9:44 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> > On Tue, 2016-01-05 at 09:11 -0800, John Fastabend wrote:
> >> When a qdisc is using per cpu stats (currently just the ingress
> >> qdisc) only the bstats are being freed. This also free's the qstats.
> >>
> >> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
> >> ---
> >
> > Acked-by: Eric Dumazet <edumazet@google.com>
> >
> > David, please add the following tag to ease backports to stable kernels:
> >
> > Fixes: 22e0f8b9322cb ("net: sched: make bstats per cpu and estimator RCU safe")
> >
> 
> Not a big deal at all but... doesn't that fix commit b0ab6f92752b9f9d8
> instead of 22e0f8b9322cb?

Hmmm... you may be right. Both were added in 3.18.

My search was based on commit adding qdisc_is_percpu_stats()
