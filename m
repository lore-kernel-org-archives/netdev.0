From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net v7 1/2] net: sched: tbf: fix the calculation of
 max_size
Date: Wed, 11 Dec 2013 11:38:40 -0800
Message-ID: <1386790720.30495.380.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1386658768-29584-1-git-send-email-yangyingliang@huawei.com>
	 <1386658768-29584-2-git-send-email-yangyingliang@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, brouer@redhat.com,
	jpirko@redhat.com, jbrouer@redhat.com
To: Yang Yingliang <yangyingliang@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f51.google.com ([209.85.160.51]:35757 "EHLO
	mail-pb0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751030Ab3LKTim (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Dec 2013 14:38:42 -0500
Received: by mail-pb0-f51.google.com with SMTP id up15so10632597pbc.10
        for <netdev@vger.kernel.org>; Wed, 11 Dec 2013 11:38:42 -0800 (PST)
In-Reply-To: <1386658768-29584-2-git-send-email-yangyingliang@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-12-10 at 14:59 +0800, Yang Yingliang wrote:
> Current max_size is caluated from rate table. Now, the rate table
> has been replaced and it's wrong to caculate max_size based on this
> rate table. It can lead wrong calculation of max_size.
> 
> The burst in kernel may be lower than user asked, because burst may gets
> some loss when transform it to buffer(E.g. "burst 40kb rate 30mbit/s")
> and it seems we cannot avoid this loss. Burst's value(max_size) based on
> rate table may be equal user asked. If a packet's length is max_size, this
> packet will be stalled in tbf_dequeue() because its length is above the
> burst in kernel so that it cannot get enough tokens. The max_size guards
> against enqueuing packet sizes above q->buffer "time" in tbf_enqueue().
> 
> To make consistent with the calculation of tokens, this patch add a helper
> psched_ns_t2l() to calculate burst(max_size) directly to fix this problem.
> 
> After this fix, we can support to using 64bit rates to calculate burst as well.
> 
> Signed-off-by: Yang Yingliang <yangyingliang@huawei.com>
> ---

Acked-by: Eric Dumazet <edumazet@google.com>
