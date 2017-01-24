From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH v2] virtio_net: fix PAGE_SIZE > 64k
Date: Tue, 24 Jan 2017 23:56:15 +0200
Message-ID: <20170124235101-mutt-send-email-mst@kernel.org>
References: <20170124221114-mutt-send-email-mst@kernel.org>
	<20170124.155331.1409241818867862249.davem@davemloft.net>
	<20170124225502-mutt-send-email-mst@kernel.org>
	<20170124.161046.824400071485171478.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, john.fastabend@gmail.com,
	linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org
To: David Miller <davem@davemloft.net>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <20170124.161046.824400071485171478.davem@davemloft.net>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/virtualization/>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

On Tue, Jan 24, 2017 at 04:10:46PM -0500, David Miller wrote:
> This works in the regimen that XDP packets always live in exactly one
> page.  That will be needed to mmap the RX ring into userspace, and it
> helps make adjust_header trivial as well.

I think the point was to avoid resets across xdp attach/detach.  If we
are doing resets now, we could do whatever buffering we want. We could
also just disable mergeable buffers for that matter.

> MTU 1500, PAGESIZE >= 4096, so a headroom of 256 is no problem, and
> we still have enough tailroom for skb_shared_info should we wrap
> the buffer into a real SKB and push it into the stack.
> 
> If you are trying to do buffering differently for virtio_net, well...
> that's a self inflicted wound as far as I can tell.

Right but I was wondering about the fact that this makes XDP_PASS
much slower than processing skbs without XDP, as truesize is huge
so we'll quickly run out of rmem space.

When XDP is used to fight DOS attacks, why isn't this a concern?

-- 
MST
