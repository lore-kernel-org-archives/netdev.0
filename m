From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 2/3] virtio-net: use per-receive queue page
	frag alloc for mergeable bufs
Date: Wed, 08 Jan 2014 14:54:20 -0500 (EST)
Message-ID: <20140108.145420.609452787528603984.davem@davemloft.net>
References: <1388095258.12212.37.camel@edumazet-glaptop2.roam.corp.google.com>
	<20140108172104.GD17404@redhat.com>
	<1389204587.26646.111.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: mwdalton@google.com, mst@redhat.com, netdev@vger.kernel.org,
	virtualization@lists.linux-foundation.org, edumazet@google.com
To: eric.dumazet@gmail.com
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1389204587.26646.111.camel@edumazet-glaptop2.roam.corp.google.com>
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

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 08 Jan 2014 10:09:47 -0800

> A physical NIC do not use a workqueue to refill its RX queue but uses
> the following strategy :
> 
> 0) Pre filling of RX ring buffer with N frames. This can use GFP_KERNEL
>    allocations with all needed (sleep/retry/shout) logic...
> 1) IRQ is handled.
> 2) Can we allocate a new buffer (GFP_ATOMIC) ?
>    If yes, we accept the frame,
>       and post the new buffer for the 'next frame'
>    If no, we drop the frame and recycle the memory for next round.

+1
