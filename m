From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [RFC Patch net-next] net_sched: make classifying lockless on ingress
Date: Mon, 23 Dec 2013 16:56:14 -0800
Message-ID: <CAM_iQpWAdsT=HX6AdK8oqPOFwzpBvPN__335Fuv3zEeS4HEWHQ@mail.gmail.com>
References: <1387582105-1789-1-git-send-email-xiyou.wangcong@gmail.com>
	<1387583344.19078.475.camel@edumazet-glaptop2.roam.corp.google.com>
	<CAM_iQpWLTL-PmiNz8k7Kv9KcHsFTennATKgbwQWXX2FN8vdxjg@mail.gmail.com>
	<1387584529.19078.482.camel@edumazet-glaptop2.roam.corp.google.com>
	<CAM_iQpXYpKE6zAAjFjzAW5KN=u7+C1gapz-bvkmVNFsNi+Jqmw@mail.gmail.com>
	<52B4FDD1.10608@intel.com>
	<52B61222.8080000@mojatatu.com>
	<52B61FA3.9050904@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jamal Hadi Salim <jhs@mojatatu.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f42.google.com ([209.85.219.42]:56877 "EHLO
	mail-oa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753093Ab3LXA4O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Dec 2013 19:56:14 -0500
Received: by mail-oa0-f42.google.com with SMTP id i4so6355287oah.15
        for <netdev@vger.kernel.org>; Mon, 23 Dec 2013 16:56:14 -0800 (PST)
In-Reply-To: <52B61FA3.9050904@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Dec 21, 2013 at 3:09 PM, John Fastabend
<john.fastabend@gmail.com> wrote:
>
> I solved this by making them per CPU and synchronizing when I hit
> an operation that required sync'ing them. Going forward if folks
> have the time to write SMP aware qdisc's that work with eventually
> consistent counters that would be great.
>

Interesting, then you have to copy the same filters and actions
to all per-cpu-ingress-qdisc, right? Also you need to handle
CPU online/offline event.

The number of CPU's grows fast today, so the total size
of such ingress qdisc would be huge if I install lots
of filters and action.
