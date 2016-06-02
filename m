From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v6 0/3] skb_array: array based FIFO for skbs
Date: Wed, 01 Jun 2016 21:51:12 -0700 (PDT)
Message-ID: <20160601.215112.20935437120251822.davem@davemloft.net>
References: <1464785601-3074-1-git-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, jasowang@redhat.com,
	eric.dumazet@gmail.com, netdev@vger.kernel.org,
	rostedt@goodmis.org, brouer@redhat.com, kvm@vger.kernel.org
To: mst@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1464785601-3074-1-git-send-email-mst@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Michael S. Tsirkin" <mst@redhat.com>
Date: Wed, 1 Jun 2016 15:54:34 +0300

> This is in response to the proposal by Jason to make tun
> rx packet queue lockless using a circular buffer.
> My testing seems to show that at least for the common usecase
> in networking, which isn't lockless, circular buffer
> with indices does not perform that well, because
> each index access causes a cache line to bounce between
> CPUs, and index access causes stalls due to the dependency.
> 
> By comparison, an array of pointers where NULL means invalid
> and !NULL means valid, can be updated without messing up barriers
> at all and does not have this issue.
> 
> On the flip side, cache pressure may be caused by using large queues.
> tun has a queue of 1000 entries by default and that's 8K.
> At this point I'm not sure this can be solved efficiently.
> The correct solution might be sizing the queues appropriately.
> 
> Here's an implementation of this idea: it can be used more
> or less whenever sk_buff_head can be used, except you need
> to know the queue size in advance.
 ...

I have no fundamental issues with this piece of infrastructure, but when
it gets included I want this series to include at least one use case.

This can be an adaptation of Jason's tun rx packet queue changes, or
similar.

Thanks.
