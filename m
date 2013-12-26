From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [RFC Patch net-next] net_sched: make classifying lockless on
 ingress
Date: Thu, 26 Dec 2013 07:02:01 -0500
Message-ID: <52BC1AB9.8010407@mojatatu.com>
References: <1387582105-1789-1-git-send-email-xiyou.wangcong@gmail.com> <1387583344.19078.475.camel@edumazet-glaptop2.roam.corp.google.com> <CAM_iQpWLTL-PmiNz8k7Kv9KcHsFTennATKgbwQWXX2FN8vdxjg@mail.gmail.com> <1387584529.19078.482.camel@edumazet-glaptop2.roam.corp.google.com> <CAM_iQpXYpKE6zAAjFjzAW5KN=u7+C1gapz-bvkmVNFsNi+Jqmw@mail.gmail.com> <52B4FDD1.10608@intel.com> <52B61222.8080000@mojatatu.com> <52B61FA3.9050904@gmail.com> <CAM_iQpWAdsT=HX6AdK8oqPOFwzpBvPN__335Fuv3zEeS4HEWHQ@mail.gmail.com> <52B924F1.9020201@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: John Fastabend <john.r.fastabend@intel.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
To: John Fastabend <john.fastabend@gmail.com>,
	Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f169.google.com ([209.85.213.169]:37094 "EHLO
	mail-ig0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752821Ab3LZMCH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Dec 2013 07:02:07 -0500
Received: by mail-ig0-f169.google.com with SMTP id hk11so27217978igb.0
        for <netdev@vger.kernel.org>; Thu, 26 Dec 2013 04:02:06 -0800 (PST)
In-Reply-To: <52B924F1.9020201@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/24/13 01:08, John Fastabend wrote:

>
> In this case I was specifically talking about statistics so the
> bstats and qstats.
>

Thats my thinking as well. Mostly control plane requests would
drive it. Assuming it is real world and not a benchmark test - then
you can afford to be loosely synchronized.

> As long as the qdisc's do not require global state this works well
> enough. However as Jamal keeps pointing out the problem is any qdisc
> which requires global state requires locking (I paraphrase but I think
> replicate the spirit correctly) and this doesn't work well with many
> CPUs. So you either replicate the qdiscs one per queue like we do in
> the mq and mqprio case effectively removing any global state or you
> develop qdiscs that don't require global state or at least work with
> eventually consistent data to avoid the constant syncing of data.
>
> I think though a qdisc per nic queue is really not as bad as you think.
> For example we do this on the tx side and it works OK. Note its per
> RX queue and not per CPU.
>

And it is as you said earlier a configuration issue.

cheers,
jamal
