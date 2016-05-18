From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH net-next] tuntap: introduce tx skb ring
Date: Wed, 18 May 2016 07:52:06 -0400
Message-ID: <20160518075206.0ca4c500@grimm.local.home>
References: <1463361421-4397-1-git-send-email-jasowang@redhat.com>
	<1463370998.18194.74.camel@edumazet-glaptop3.roam.corp.google.com>
	<57397C14.1080701@redhat.com>
	<20160518101359.37f5343b@redhat.com>
	<573C42B4.6040708@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jesper Dangaard Brouer <brouer@redhat.com>,
	Eric Dumazet <eric.dumazet@gmail.com>, davem@davemloft.net,
	mst@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Peter Zijlstra <peterz@infradead.org>
To: Jason Wang <jasowang@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <573C42B4.6040708@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 18 May 2016 18:23:48 +0800
Jason Wang <jasowang@redhat.com> wrote:

>
> >
> >
> > Maybe Steven Rostedt have an even better ring queue implementation
> > already avail in the kernel?
> >  
> 
> You mean ring buffer in tracing? Not sure, but it looks rather complex 
> at first glance.

Yes it is, and I'm not sure it would be appropriate here or not. The
tracing ring buffer is highly tuned to be lockless and per cpu
(allocates a buffer per cpu), it also does not need to disable
interrupts and can be used in NMI context.

The complexity comes from being able to locklessly swap out pages from
the ring buffer to send across the network or to disk while a record is
happening.

Perf has a simpler ring buffer made for mmapping, but it's still rather
coupled with the perf core. It would be nice to make that ring buffer a
bit more generic and not so tied to perf itself.

-- Steve
