From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [RFC PATCH 12/12] net: sched: pfifo_fast new option to deque
 multiple pkts
Date: Wed, 30 Dec 2015 10:13:16 -0800
Message-ID: <56841EBC.3000102@gmail.com>
References: <20151230175000.26257.41532.stgit@john-Precision-Tower-5810> <20151230175530.26257.2642.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: john.r.fastabend@intel.com, netdev@vger.kernel.org
To: daniel@iogearbox.net, eric.dumazet@gmail.com, jhs@mojatatu.com,
	aduyck@mirantis.com, brouer@redhat.com, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f182.google.com ([209.85.192.182]:34606 "EHLO
	mail-pf0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750814AbbL3SNa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Dec 2015 13:13:30 -0500
Received: by mail-pf0-f182.google.com with SMTP id e65so92290420pfe.1
        for <netdev@vger.kernel.org>; Wed, 30 Dec 2015 10:13:30 -0800 (PST)
In-Reply-To: <20151230175530.26257.2642.stgit@john-Precision-Tower-5810>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 15-12-30 09:55 AM, John Fastabend wrote:
> Now that pfifo_fast is using the alf_queue data structures we can
> dequeue multiple skbs and save some overhead.
> 
> This works because the bulk dequeue logic accepts skb lists already.
> 
> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
> ---

oops I didn't mean to send this it obviously doesn't work because
until you have 8 skbs nothing gets dequeued. This was just a test
patch I was looking at for perf numbers. Maybe it provides some
insight into how we could build a pfifo_bulk or add an option to
pfifo_fast to dequeue multiple pkts at a time. The trick is to
sort out how long to wait for packets to build up or possibly
just remove this line,

+	if (this_cpu_ptr(qdisc->cpu_qstats)->qlen < 8)
+		return NULL;

And opportunistically pull packets out at the risk of over-running
the driver if those are large skbs.

.John
