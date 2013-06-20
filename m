From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net-next rfc 1/3] net: avoid high order memory allocation for
 queues by using flex array
Date: Wed, 19 Jun 2013 23:05:12 -0700
Message-ID: <1371708312.3252.359.camel@edumazet-glaptop>
References: <1371620452-49349-1-git-send-email-jasowang@redhat.com>
	  <1371620452-49349-2-git-send-email-jasowang@redhat.com>
	  <1371623518.3252.267.camel@edumazet-glaptop>
	  <20130619091132.GA2816@redhat.com>
	 <1371635763.3252.289.camel@edumazet-glaptop> <51C28FA7.2070901@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "Michael S. Tsirkin" <mst@redhat.com>, davem@davemloft.net,
	edumazet@google.com, hkchu@google.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Jason Wang <jasowang@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <51C28FA7.2070901@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2013-06-20 at 13:14 +0800, Jason Wang wrote:

> A drawback of NETIF_F_LLTX is that we may contend on qdisc lock
> especially when we have a huge number of tx queues.

For your information loopback driver is LLTX, and there is no qdisc on
it, unless you specifically add one.

Once you add a qdisc on a device, you hit the typical contention on a
spinlock. But its hard to design a parallel qdisc. So far nobody did
that.
