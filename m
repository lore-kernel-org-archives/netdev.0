From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH] virtio-net: fix a race on 32bit arches
Date: Wed, 6 Jun 2012 23:19:43 +0300
Message-ID: <20120606201942.GA23405@redhat.com>
References: <1338971724.2760.3913.camel@edumazet-glaptop>
	<1338972341.2760.3944.camel@edumazet-glaptop>
	<20120606111357.GA15070@redhat.com>
	<1338988210.2760.4485.camel@edumazet-glaptop>
	<20120606144941.GA17092@redhat.com>
	<1338995944.26966.6.camel@edumazet-glaptop>
	<20120606161715.GA17575@redhat.com>
	<1339002782.26966.22.camel@edumazet-glaptop>
	<20120606184351.GA20380@redhat.com>
	<1339013171.26966.60.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org,
	Stephen Hemminger <shemminger@vyatta.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <1339013171.26966.60.camel@edumazet-glaptop>
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

On Wed, Jun 06, 2012 at 10:06:11PM +0200, Eric Dumazet wrote:
> On Wed, 2012-06-06 at 21:43 +0300, Michael S. Tsirkin wrote:
> 
> > 1. We are trying to look at counters for purposes of tuning the device.
> > E.g. if ethtool reports packets and bytes, we'd like to calculate
> > average packet size by bytes/packets.
> > 
> > If both counters are read atomically the metric becomes more exact.
> > Not a must but nice to have.
> > 
> 
> metrics are exact right now.

Yes, but they are not synchronised between themselves.
E.g. you can in theory have a report where #of packets > #of bytes.

I know there's no guarantee they are synchronised
on an arbitrary device but if they are, without
slowing fast path, it's nice.
