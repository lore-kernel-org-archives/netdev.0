From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [net-next PATCH] bpf: cpumap fix potential lost wake-up problem
Date: Mon, 23 Oct 2017 22:34:37 +0200
Message-ID: <59EE525D.6090903@iogearbox.net>
References: <150878036830.4768.8540758939081367484.stgit@firesoul>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Rik van Riel <riel@redhat.com>,
        Daniel Borkmann <borkmann@iogearbox.net>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>
To: Jesper Dangaard Brouer <brouer@redhat.com>, netdev@vger.kernel.org,
        "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:42124 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751216AbdJWUej (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 23 Oct 2017 16:34:39 -0400
In-Reply-To: <150878036830.4768.8540758939081367484.stgit@firesoul>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/23/2017 07:39 PM, Jesper Dangaard Brouer wrote:
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

SOB missing ...
