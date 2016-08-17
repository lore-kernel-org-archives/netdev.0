From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [RFC PATCH 10/13] net: sched: lockless support for netif_schedule
Date: Wed, 17 Aug 2016 12:46:29 -0700
Message-ID: <57B4BF15.2000109@gmail.com>
References: <20160817193120.27032.20918.stgit@john-Precision-Tower-5810>
 <20160817193738.27032.25592.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: john.r.fastabend@intel.com, netdev@vger.kernel.org,
	davem@davemloft.net
To: xiyou.wangcong@gmail.com, jhs@mojatatu.com,
	alexei.starovoitov@gmail.com, eric.dumazet@gmail.com,
	brouer@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:36040 "EHLO
	mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752406AbcHQTqp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Aug 2016 15:46:45 -0400
Received: by mail-pf0-f196.google.com with SMTP id y134so8682903pfg.3
        for <netdev@vger.kernel.org>; Wed, 17 Aug 2016 12:46:45 -0700 (PDT)
In-Reply-To: <20160817193738.27032.25592.stgit@john-Precision-Tower-5810>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-08-17 12:37 PM, John Fastabend wrote:
> netif_schedule uses a bit QDISC_STATE_SCHED to tell the qdisc layer
> if a run of the qdisc has been scheduler. This is important when
> tearing down qdisc instances. We can rcu_free an instance for example
> if its possible that we might have outstanding references to it.
> 
> Perhaps more importantly in the per cpu lockless case we need to
> schedule a run of the qdisc on all qdiscs that are enqueu'ing packets
> and hitting the gso_skb requeue logic or else the skb may get stuck
> on the gso_skb queue without anything to finish the xmit.
> 
> This patch uses a reference counter instead of a bit to account for
> the multiple CPUs.
> ---

oops the commit message is incorrect here it actually uses a per cpu
state bitmask to track this.
