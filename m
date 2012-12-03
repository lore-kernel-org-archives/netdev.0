From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tun: only queue packets on device
Date: Mon, 03 Dec 2012 13:41:32 -0500 (EST)
Message-ID: <20121203.134132.558381056546064453.davem@davemloft.net>
References: <20121203131942.GA27953@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jasowang@redhat.com, nhorman@tuxdriver.com,
	ramirose@gmail.com, linux-kernel@vger.kernel.org
To: mst@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20121203131942.GA27953@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Michael S. Tsirkin" <mst@redhat.com>
Date: Mon, 3 Dec 2012 15:19:43 +0200

> Historically tun supported two modes of operation:
> - in default mode, a small number of packets would get queued
>   at the device, the rest would be queued in qdisc
> - in one queue mode, all packets would get queued at the device
> 
> This might have made sense up to a point where we made the
> queue depth for both modes the same and set it to
> a huge value (500) so unless the consumer
> is stuck the chance of losing packets is small.
> 
> Thus in practice both modes behave the same, but the
> default mode has some problems:
> - if packets are never consumed, fragments are never orphaned
>   which cases a DOS for sender using zero copy transmit
> - overrun errors are hard to diagnose: fifo error is incremented
>   only once so you can not distinguish between
>   userspace that is stuck and a transient failure,
>   tcpdump on the device does not show any traffic
> 
> Userspace solves this simply by enabling IFF_ONE_QUEUE
> but there seems to be little point in not doing the
> right thing for everyone, by default.
> 
> Signed-off-by: Michael S. Tsirkin <mst@redhat.com>

Now that TUN_NO_QUEUE has no real effect and is a NOP, please document
it as such both in if_tun.h and the places in the driver that flip the
bit based upon userspace requests.

Thanks.
