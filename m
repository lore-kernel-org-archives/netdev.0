From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [rfc net-next v6 2/3] virtio_net: multiqueue support
Date: Tue, 13 Nov 2012 08:40:26 +0200
Message-ID: <20121113064026.GA27416@redhat.com>
References: <1351591403-23065-1-git-send-email-jasowang@redhat.com>
	<1351591403-23065-3-git-send-email-jasowang@redhat.com>
	<87y5igyhyg.fsf@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: krkumar2@in.ibm.com, kvm@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org, edumazet@google.com,
	davem@davemloft.net
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <87y5igyhyg.fsf@rustcorp.com.au>
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

On Mon, Nov 05, 2012 at 11:38:39AM +1030, Rusty Russell wrote:
> > @@ -924,11 +1032,10 @@ static void virtnet_get_ringparam(struct net_device *dev,
> >  {
> >  	struct virtnet_info *vi = netdev_priv(dev);
> >  
> > -	ring->rx_max_pending = virtqueue_get_vring_size(vi->rvq);
> > -	ring->tx_max_pending = virtqueue_get_vring_size(vi->svq);
> > +	ring->rx_max_pending = virtqueue_get_vring_size(vi->rq[0].vq);
> > +	ring->tx_max_pending = virtqueue_get_vring_size(vi->sq[0].vq);
> >  	ring->rx_pending = ring->rx_max_pending;
> >  	ring->tx_pending = ring->tx_max_pending;
> > -
> >  }
> 
> This assumes all vqs are the same size.  I think this should probably
> check: for mq mode, use the first vq, otherewise use the 0th.

For rx_pending/tx_pending I think what is required here is the
actual number of outstanding buffers.
Dave, Eric - right?

So this should be the total over all rings and to be useful,
rx_max_pending/tx_max_pending should be the total too.

> For bonus points, check this assertion at probe time.

Looks like we can easily support different queues too.

-- 
MST
