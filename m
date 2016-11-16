From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [RFC PATCH 2/2] ptr_ring_ll: pop/push multiple objects at once
Date: Wed, 16 Nov 2016 07:23:25 +0200
Message-ID: <20161116072120-mutt-send-email-mst@kernel.org>
References: <20161111043857.1547.70337.stgit@john-Precision-Tower-5810>
 <20161111044432.1547.65342.stgit@john-Precision-Tower-5810>
 <20161115010140-mutt-send-email-mst@kernel.org>
 <582BE39B.9050007@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jasowang@redhat.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <582BE39B.9050007@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Nov 15, 2016 at 08:42:03PM -0800, John Fastabend wrote:
> On 16-11-14 03:06 PM, Michael S. Tsirkin wrote:
> > On Thu, Nov 10, 2016 at 08:44:32PM -0800, John Fastabend wrote:
> >> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
> > 
> > This will naturally reduce the cache line bounce
> > costs, but so will a _many API for ptr-ring,
> > doing lock-add many-unlock.
> > 
> > the number of atomics also scales better with the lock:
> > one per push instead of one per queue.
> > 
> > Also, when can qdisc use a _many operation?
> > 
> 
> On dequeue we can pull off many skbs instead of one at a time and
> then either (a) pass them down as an array to the driver (I started
> to write this on top of ixgbe and it seems like a win) or (b) pass
> them one by one down to the driver and set the xmit_more bit correctly.
> 
> The pass one by one also seems like a win because we avoid the lock
> per skb.
> 
> On enqueue qdisc side its a bit more evasive to start doing this.
> 
> 
> [...]


I see. So we could wrap __ptr_ring_consume and
implement __skb_array_consume. You can call that
in a loop under a lock. I would limit it to something
small like 16 pointers, to make sure lock contention is
not an issue.

-- 
MST
