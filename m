From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] vhost-net: fall back to vmalloc if high-order
 allocation fails
Date: Sun, 27 Jan 2013 22:11:37 -0500 (EST)
Message-ID: <20130127.221137.1761549497221263360.davem@davemloft.net>
References: <87k3r31vbc.fsf@silenus.orebokech.com>
	<20130123210411.GA9055@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: romain@orebokech.com, kvm@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: mst@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130123210411.GA9055@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Michael S. Tsirkin" <mst@redhat.com>
Date: Wed, 23 Jan 2013 23:04:11 +0200

> Maybe we should try and reduce our memory usage,
> I will look into this.

As has been pointed out, 32K of the size is from those iovecs in
the queues.

The size of this structure is frankly offensive, and even if you add
some levels of indirection even just one iovec chunk is 16K on 64-bit
which is in my opinion still unacceptably large.

TCP sockets aren't even %25 the size of this beast. :-)

I'm not going to apply this vmalloc patch, because if I apply it the
fundamental problem here just gets swept under the carpet even longer.

Sorry.
