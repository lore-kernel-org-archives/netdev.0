From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCHv3] virtio-spec: virtio network device multiqueue support
Date: Sun, 9 Sep 2012 15:40:33 +0300
Message-ID: <20120909124033.GA2986@redhat.com>
References: <20120906120828.GA1534@redhat.com>
 <50493D04.1090408@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kvm@vger.kernel.org,
	virtualization@lists.linux-foundation.org
To: Sasha Levin <levinsasha928@gmail.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <50493D04.1090408@gmail.com>
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

On Fri, Sep 07, 2012 at 02:17:08AM +0200, Sasha Levin wrote:
> Hi Michael,
> 
> On 09/06/2012 02:08 PM, Michael S. Tsirkin wrote:
> > Add multiqueue support to virtio network device.
> > Add a new feature flag VIRTIO_NET_F_MULTIQUEUE for this feature, a new
> > configuration field max_virtqueue_pairs to detect supported number of
> > virtqueues as well as a new command VIRTIO_NET_CTRL_STEERING to program
> > packet steering.
> > 
> > Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
> 
> Some comments about the change:
> 
>  - "The following four read-only fields only exists if VIRTIO_NET_F_MULTIQUEUE
> is set." => Should be "exist" (I think).
> 
>  - "When rule is set to VIRTIO_NET_CTRL_STEERING_RX_FOLLOWS_TX packets are
> steered by driver to the first (param+1) multiqueue virtqueues
> transmitq1...transmitqN;" - Why param+1?  I thought we ignore the default
> transmit/receive in this case.
> 
>  - "As selecting a specific steering ais n optimization feature" - "is an".
> 
>  - It's mentioned several times that the ability to read the steering rule from
> the virtio-net config is there for debug reasons. Is it really necessary? I
> think it's the first time I see debug features go in as part of the spec.

Yes, let features -> less stuff to debug. I'll drop it.

>  - I'm slightly confused, why are there both receive and transmit steering? I
> can't find a difference in the way to configure the rule for transmit and
> receive.

This paragraph is there to address this:
	Driver selects an active steering rule using VIRTIO_NET_CTRL_STEERING
	command (this controls both which virtqueue is selected for a given
	packet for receive and notifies the device which virtqueues are about to
	be used for transmit).

How can I clarify this better?

> Is it a plan for the future to allow different rules for tx and rx? If
> so, shouldn't we use different ctrl commands (
> VIRTIO_NET_CTRL_TX_STEERING/VIRTIO_NET_CTRL_RX_STEERING)?

I don't see separate steering as very useful:
it does not work for RX follows TX or for TX follows
RX, and separate commands imediately create lots of
options with behaviour which hard to define.
For example if you configure SINGLE on TX but RX_FOLLOWS_TX
on RX what does it mean?

>  - "When rule is set to VIRTIO_NET_CTRL_STEERING_SINGLE all packets are steered
> to the default virtqueue receveq (0);" - "receiveq (0)"
> 
> 
> 
> Thanks,
> Sasha
