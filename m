From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [rfc net-next v6 2/3] virtio_net: multiqueue support
Date: Sun, 18 Nov 2012 11:13:54 +0200
Message-ID: <20121118091354.GA31775@redhat.com>
References: <1351591403-23065-1-git-send-email-jasowang@redhat.com>
	<1351591403-23065-3-git-send-email-jasowang@redhat.com>
	<87y5igyhyg.fsf@rustcorp.com.au>
	<20121113064026.GA27416@redhat.com>
	<1353112529.2743.83.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: krkumar2@in.ibm.com, kvm@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org, edumazet@google.com,
	davem@davemloft.net
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <1353112529.2743.83.camel@bwh-desktop.uk.solarflarecom.com>
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

On Sat, Nov 17, 2012 at 12:35:29AM +0000, Ben Hutchings wrote:
> On Tue, 2012-11-13 at 08:40 +0200, Michael S. Tsirkin wrote:
> > On Mon, Nov 05, 2012 at 11:38:39AM +1030, Rusty Russell wrote:
> > > > @@ -924,11 +1032,10 @@ static void virtnet_get_ringparam(struct net_device *dev,
> > > >  {
> > > >  	struct virtnet_info *vi = netdev_priv(dev);
> > > >  
> > > > -	ring->rx_max_pending = virtqueue_get_vring_size(vi->rvq);
> > > > -	ring->tx_max_pending = virtqueue_get_vring_size(vi->svq);
> > > > +	ring->rx_max_pending = virtqueue_get_vring_size(vi->rq[0].vq);
> > > > +	ring->tx_max_pending = virtqueue_get_vring_size(vi->sq[0].vq);
> > > >  	ring->rx_pending = ring->rx_max_pending;
> > > >  	ring->tx_pending = ring->tx_max_pending;
> > > > -
> > > >  }
> > > 
> > > This assumes all vqs are the same size.  I think this should probably
> > > check: for mq mode, use the first vq, otherewise use the 0th.
> > 
> > For rx_pending/tx_pending I think what is required here is the
> > actual number of outstanding buffers.
> > Dave, Eric - right?
> > 
> > So this should be the total over all rings and to be useful,
> > rx_max_pending/tx_max_pending should be the total too.
> 
> So far as I know, all current implementations use the number of
> descriptors per ring here. virtio_net should be consistent with this.
> 
> Ben.

Problem is, it could in theory be different between rings. I guess we
could use the maximum.

What's the right thing to do for rx_pending - I am guessing
we want the current outstanding packets right?


> > > For bonus points, check this assertion at probe time.
> > 
> > Looks like we can easily support different queues too.
> > 
> 
> -- 
> Ben Hutchings, Staff Engineer, Solarflare
> Not speaking for my employer; that's the marketing department's job.
> They asked us to note that Solarflare product names are trademarked.
