From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] virtio-net: fix a race on 32bit arches
Date: Wed, 06 Jun 2012 22:06:11 +0200
Message-ID: <1339013171.26966.60.camel@edumazet-glaptop>
References: <1338971724.2760.3913.camel@edumazet-glaptop>
	<1338972341.2760.3944.camel@edumazet-glaptop>
	<20120606111357.GA15070@redhat.com>
	<1338988210.2760.4485.camel@edumazet-glaptop>
	<20120606144941.GA17092@redhat.com>
	<1338995944.26966.6.camel@edumazet-glaptop>
	<20120606161715.GA17575@redhat.com>
	<1339002782.26966.22.camel@edumazet-glaptop>
	<20120606184351.GA20380@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org,
	Stephen Hemminger <shemminger@vyatta.com>
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <20120606184351.GA20380@redhat.com>
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

On Wed, 2012-06-06 at 21:43 +0300, Michael S. Tsirkin wrote:

> 1. We are trying to look at counters for purposes of tuning the device.
> E.g. if ethtool reports packets and bytes, we'd like to calculate
> average packet size by bytes/packets.
> 
> If both counters are read atomically the metric becomes more exact.
> Not a must but nice to have.
> 

metrics are exact right now.

As soon as you read a value, it might already have changed.

Maybe you want to stop_machine() to make sure all the metrics you want
are 'exact' ;)

> 2. 32 bit systems have some overhead because of the seqlock.
> virtio could instead simply keep tx counters in the queue structure, and
> get the tx lock when they are read.
> 

But then you need atomic64 stuff, have you an idea of the cost of such
primitives on 32bit ?

3. use 32bit counters on 32bit arches, as many drivers still do ?
