From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [net-next PATCH] bpf: cpumap fix potential lost wake-up problem
Date: Tue, 24 Oct 2017 06:46:32 +0200
Message-ID: <20171024064632.56a668eb@redhat.com>
References: <150878036830.4768.8540758939081367484.stgit@firesoul>
        <59EE525D.6090903@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "Michael S. Tsirkin" <mst@redhat.com>,
        Rik van Riel <riel@redhat.com>,
        Daniel Borkmann <borkmann@iogearbox.net>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        brouer@redhat.com
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:63289 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751336AbdJXEqk (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 24 Oct 2017 00:46:40 -0400
In-Reply-To: <59EE525D.6090903@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 23 Oct 2017 22:34:37 +0200
Daniel Borkmann <daniel@iogearbox.net> wrote:

> On 10/23/2017 07:39 PM, Jesper Dangaard Brouer wrote:
> > As pointed out by Michael, commit 1c601d829ab0 ("bpf: cpumap xdp_buff
> > to skb conversion and allocation") contains a classical example of the
> > potential lost wake-up problem.
> >
> > We need to recheck the condition __ptr_ring_empty() after changing
> > current->state to TASK_INTERRUPTIBLE, this avoids a race between
> > wake_up_process() and schedule(). After this, a race with
> > wake_up_process() will simply change the state to TASK_RUNNING, and
> > the schedule() call not really put us to sleep.
> >
> > Fixes: 1c601d829ab0 ("bpf: cpumap xdp_buff to skb conversion and allocation")
> > Reported-by: "Michael S. Tsirkin" <mst@redhat.com>  
> 
> SOB missing ...

Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>

Damn... DaveM do I need to resubmit? Or will patchwork pickup above SOB?

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  LinkedIn: http://www.linkedin.com/in/brouer
