From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH] virtio-net: fix a race on 32bit arches
Date: Wed, 6 Jun 2012 23:16:20 +0300
Message-ID: <20120606201620.GA23358@redhat.com>
References: <1338971724.2760.3913.camel@edumazet-glaptop>
	<1338972341.2760.3944.camel@edumazet-glaptop>
	<20120606111357.GA15070@redhat.com>
	<1338988210.2760.4485.camel@edumazet-glaptop>
	<20120606144941.GA17092@redhat.com>
	<20120606081432.6b602065@nehalam.linuxnetplumber.net>
	<20120606185107.GA20503@redhat.com>
	<1339012441.26966.48.camel@edumazet-glaptop>
	<20120606195814.GA20677@redhat.com>
	<1339013289.26966.62.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org,
	Stephen Hemminger <shemminger@vyatta.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <1339013289.26966.62.camel@edumazet-glaptop>
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

On Wed, Jun 06, 2012 at 10:08:09PM +0200, Eric Dumazet wrote:
> On Wed, 2012-06-06 at 22:58 +0300, Michael S. Tsirkin wrote:
> 
> > Absolutely, I am talking about virtio here.  I'm not kicking
> > u64_stats_sync idea I am just saying that simple locking
> > would work for virtio and might be better as it
> > gives us a way to get counters atomically.
> 
> Which lock do you own in the RX path ?

We can just disable napi, everything is updated from napi callback.

> You'll have to add a lock in fast path. This sounds really a bad choice
> to me.

.ndo_get_stats64 is not data path though, is it?

-- 
MST
