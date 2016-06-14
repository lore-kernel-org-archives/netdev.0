From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [PATCH v8 5/5] skb_array: resize support
Date: Tue, 14 Jun 2016 14:21:13 +0200
Message-ID: <20160614142113.1f0391d0@redhat.com>
References: <1465851234-13558-1-git-send-email-mst@redhat.com>
	<20160613235450-mutt-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, Jason Wang <jasowang@redhat.com>,
	Eric Dumazet <eric.dumazet@gmail.com>, davem@davemloft.net,
	netdev@vger.kernel.org, Steven Rostedt <rostedt@goodmis.org>,
	kvm@vger.kernel.org, brouer@redhat.com
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160613235450-mutt-send-email-mst@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 13 Jun 2016 23:54:50 +0300
"Michael S. Tsirkin" <mst@redhat.com> wrote:

> Update skb_array after ptr_ring API changes.
> 
> Signed-off-by: Michael S. Tsirkin <mst@redhat.com>

Acked-by: Jesper Dangaard Brouer <brouer@redhat.com>
Tested-by: Jesper Dangaard Brouer <brouer@redhat.com>

Also did resize unit test:
 https://github.com/netoptimizer/prototype-kernel/commit/af0b4d7e7261e9

The parallel benchmark:
 https://github.com/netoptimizer/prototype-kernel/blob/master/kernel/lib/skb_array_parallel01.c

Have been adjusted to use the non-BH variant of the lock.  And the
parallel benchmark results, where a single producer and a single
consumer CPU runs concurrently, and the queue always partly full
(optimal case for minimize cache-contention):

On CPU i7-4790K @ 4.00GHz:
 - Enqueue 32 cycles(tsc) 8.162 ns 
 - Dequeue 33 cycles(tsc) 8.417 ns

Notice this is an extremely good concurrency results, as it is very
close to the optimal case benchmark 26 cycles, when running
enqueue+dequeue on the same CPU in a tight loop[2].  

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer

[2] https://github.com/netoptimizer/prototype-kernel/blob/master/kernel/lib/skb_array_bench01.c
