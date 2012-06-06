From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] virtio-net: fix a race on 32bit arches
Date: Wed, 06 Jun 2012 21:54:01 +0200
Message-ID: <1339012441.26966.48.camel@edumazet-glaptop>
References: <1338971724.2760.3913.camel@edumazet-glaptop>
	 <1338972341.2760.3944.camel@edumazet-glaptop>
	 <20120606111357.GA15070@redhat.com>
	 <1338988210.2760.4485.camel@edumazet-glaptop>
	 <20120606144941.GA17092@redhat.com>
	 <20120606081432.6b602065@nehalam.linuxnetplumber.net>
	 <20120606185107.GA20503@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	Jason Wang <jasowang@redhat.com>, netdev@vger.kernel.org,
	rusty@rustcorp.com.au, linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120606185107.GA20503@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2012-06-06 at 21:51 +0300, Michael S. Tsirkin wrote:

> BTW for cards that do implement the counters in software,
> under xmit lock, is anything wrong with simply taking the xmit lock
> when we get the stats instead of the per-cpu trick + seqlock?
> 

I still dont understand why you would do that.

Most modern machines are 64bits, so there is no seqlock overhead,
nothing at all.

If you focus on 32bit hardware, just stick on 32bit counters ?

Note that most u64_stats_sync users are virtual drivers, without xmit
lock (LLTX drivers)
