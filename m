From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: sock: validate data_len before allocating skb in
 sock_alloc_send_pskb()
Date: Thu, 31 May 2012 08:20:32 +0200
Message-ID: <1338445232.2760.1171.camel@edumazet-glaptop>
References: <20120530054702.6146.8503.stgit@amd-6168-8-1.englab.nay.redhat.com>
	 <1338360383.2760.84.camel@edumazet-glaptop>
	 <20120530.030205.1337682162603770949.davem@davemloft.net>
	 <4FC708EE.2020908@redhat.com> <20120531060201.GA13158@redhat.com>
	 <4FC70BA8.5060200@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "Michael S. Tsirkin" <mst@redhat.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, stable@vger.kernel.org
To: Jason Wang <jasowang@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4FC70BA8.5060200@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2012-05-31 at 14:11 +0800, Jason Wang wrote:

> Not affected, only code duplication. It's no harm the check the data_len 
> again for packet sockets, so better to unify the code and fix the issue 
> in one place?

As a matter of fact, we currently allocate order-0 pages, but it could
be nice trying to use order-1 or order-2 pages, on arches where
PAGE_SIZE is so small (4096 bytes)

So lets do this test in sock_alloc_send_pskb() to allow future changes.

af_unix is kind of special, because it tries to lower risk of high order
linear allocation failures. And for small sizes, it wants linear skbs to
have no performance regression (prior kernels were allocating linear
skbs)
