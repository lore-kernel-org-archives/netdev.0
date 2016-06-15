From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v8 0/5] skb_array: array based FIFO for skbs
Date: Wed, 15 Jun 2016 13:59:01 -0700 (PDT)
Message-ID: <20160615.135901.2098213128968877884.davem@davemloft.net>
References: <20160613235426-mutt-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, jasowang@redhat.com,
	eric.dumazet@gmail.com, netdev@vger.kernel.org,
	rostedt@goodmis.org, brouer@redhat.com, kvm@vger.kernel.org
To: mst@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160613235426-mutt-send-email-mst@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Michael S. Tsirkin" <mst@redhat.com>
Date: Mon, 13 Jun 2016 23:54:26 +0300

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

Series applied to net-next, thanks.
