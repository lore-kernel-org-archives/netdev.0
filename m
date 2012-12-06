From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCHv5] virtio-spec: virtio network device RFS support
Date: Thu, 6 Dec 2012 22:29:21 +0200
Message-ID: <20121206202921.GB4340@redhat.com>
References: <20121203105843.GA26194@redhat.com>
	<1354739966.2655.25.camel@bwh-desktop.uk.solarflarecom.com>
	<20121206081320.GD10837@redhat.com>
	<1354824194.2828.6.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kvm@vger.kernel.org,
	virtualization@lists.linux-foundation.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <1354824194.2828.6.camel@bwh-desktop.uk.solarflarecom.com>
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

On Thu, Dec 06, 2012 at 08:03:14PM +0000, Ben Hutchings wrote:
> On Thu, 2012-12-06 at 10:13 +0200, Michael S. Tsirkin wrote:
> > On Wed, Dec 05, 2012 at 08:39:26PM +0000, Ben Hutchings wrote:
> > > On Mon, 2012-12-03 at 12:58 +0200, Michael S. Tsirkin wrote:
> > > > Add RFS support to virtio network device.
> > > > Add a new feature flag VIRTIO_NET_F_RFS for this feature, a new
> > > > configuration field max_virtqueue_pairs to detect supported number of
> > > > virtqueues as well as a new command VIRTIO_NET_CTRL_RFS to program
> > > > packet steering for unidirectional protocols.
> > > [...]
> > > > +Programming of the receive flow classificator is implicit.
> > > > + Transmitting a packet of a specific flow on transmitqX will cause incoming
> > > > + packets for this flow to be steered to receiveqX.
> > > > + For uni-directional protocols, or where no packets have been transmitted
> > > > + yet, device will steer a packet to a random queue out of the specified
> > > > + receiveq0..receiveqn.
> > > [...]
> > > 
> > > It doesn't seem like this is usable to implement accelerated RFS in the
> > > guest, though perhaps that doesn't matter.
> > 
> > What is the issue? Could you be more explicit please?
> > 
> > It seems to work pretty well: if we have
> > # of queues >= # of cpus, incoming TCP_STREAM into
> > guest scales very nicely without manual tweaks in guest.
> > 
> > The way it works is, when guest sends a packet driver
> > select the rx queue that we want to use for incoming
> > packets for this slow, and transmit on the matching tx queue.
> > This is exactly what text above suggests no?
> 
> Yes, I get that.
> 
> > >  On the host side, presumably
> > > you'll want vhost_net to do the equivalent of sock_rps_record_flow() -
> > > only without a socket?  But in any case, that requires an rxhash, so I
> > > don't see how this is supposed to work.
> > > 
> > > Ben.
> > 
> > Host should just do what guest tells it to.
> > On the host side we build up the steering table as we get packets
> > to transmit. See the code in drivers/net/tun.c in recent
> > kernels.
> > 
> > Again this actually works fine - what are the problems that you see?
> > Could you give an example please?
> 
> I'm not saying it doesn't work in its own way, I just don't see how you
> would make it work with the existing RFS!
> 
> Since this doesn't seem to be intended to have *any* connection with the
> existing core networking feature called RFS, perhaps you could find a
> different name for it.
> 
> Ben.


Ah I see what you mean. We started out calling this feature "multiqueue"
Rusty suggested "RFS" since it gives similar functionality to RFS but in
device: it has receive steering logic per flow as part of the device.

Maybe simply adding a statement similar to the one above would be
sufficient to avoid confusion?


> -- 
> Ben Hutchings, Staff Engineer, Solarflare
> Not speaking for my employer; that's the marketing department's job.
> They asked us to note that Solarflare product names are trademarked.
