From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH] bpf: cpumap fix potential lost wake-up problem
Date: Tue, 24 Oct 2017 18:40:48 +0900 (KST)
Message-ID: <20171024.184048.1933890434085798489.davem@davemloft.net>
References: <150878036830.4768.8540758939081367484.stgit@firesoul>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mst@redhat.com, riel@redhat.com,
        borkmann@iogearbox.net, alexei.starovoitov@gmail.com
To: brouer@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:58276 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751604AbdJXJkx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 24 Oct 2017 05:40:53 -0400
In-Reply-To: <150878036830.4768.8540758939081367484.stgit@firesoul>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesper Dangaard Brouer <brouer@redhat.com>
Date: Mon, 23 Oct 2017 19:39:28 +0200

> As pointed out by Michael, commit 1c601d829ab0 ("bpf: cpumap xdp_buff
> to skb conversion and allocation") contains a classical example of the
> potential lost wake-up problem.
> 
> We need to recheck the condition __ptr_ring_empty() after changing
> current->state to TASK_INTERRUPTIBLE, this avoids a race between
> wake_up_process() and schedule(). After this, a race with
> wake_up_process() will simply change the state to TASK_RUNNING, and
> the schedule() call not really put us to sleep.
> 
> Fixes: 1c601d829ab0 ("bpf: cpumap xdp_buff to skb conversion and allocation")
> Reported-by: "Michael S. Tsirkin" <mst@redhat.com>

Applied.
