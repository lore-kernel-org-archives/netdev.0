From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH v2 net-next] net: sched: run ingress qdisc without locks
Date: Mon, 04 May 2015 18:27:36 -0700
Message-ID: <55481C88.2000007@plumgrid.com>
References: <1430544448-19777-1-git-send-email-ast@plumgrid.com>	<20150503174208.5b1548ba@redhat.com>	<5546FFCB.50903@plumgrid.com> <20150504130405.3ff6672e@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	John Fastabend <john.r.fastabend@intel.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Daniel Borkmann <daniel@iogearbox.net>, netdev@vger.kernel.org
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f173.google.com ([209.85.192.173]:34754 "EHLO
	mail-pd0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751068AbbEEB1i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 May 2015 21:27:38 -0400
Received: by pdbqa5 with SMTP id qa5so178846288pdb.1
        for <netdev@vger.kernel.org>; Mon, 04 May 2015 18:27:37 -0700 (PDT)
In-Reply-To: <20150504130405.3ff6672e@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 5/4/15 4:04 AM, Jesper Dangaard Brouer wrote:
>
> How do you activate the ingress code path?
>
> I'm just doing (is this enough?):
>   export DEV=eth4
>   tc qdisc add dev $DEV handle ffff: ingress

yes. plus my numbers also include u32 classifier.

> I re-ran the experiment, and I can also only show a 2.68ns
> improvement.  This is rather strange, and I cannot explain it.
>
> The lock clearly shows up in perf report[1] with 12.23% raw_spin_lock,
> and perf report[2] it clearly gone, but we don't see a 12% improvement
> in performance, but around 4.7%.

It's indeed puzzling. Hopefully intel experts can chime in.

> The "cost" of activating the ingress qdisc is also interesting:
>   (1/25398057*10^9)-(1/16989315*10^9) = -19.49 ns
>   (1/25398057*10^9)-(1/17800496*10^9) = -16.81 ns

yep, we're working hard on reducing it.
btw the cost of enabling rps without using it is ~8ns.
Our line rate goal is still a bit far, but hopefully getting closer :)
