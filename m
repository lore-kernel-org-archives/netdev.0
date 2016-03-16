From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [RFC v2 -next 1/2] virtio: Start feature MTU support
Date: Wed, 16 Mar 2016 20:29:58 +0200
Message-ID: <20160316202625-mutt-send-email-mst@redhat.com>
References: <1458075853-14789-1-git-send-email-aconole@redhat.com>
	<1458075853-14789-2-git-send-email-aconole@redhat.com>
	<20160316112314.4510d386@samsung9>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <20160316112314.4510d386@samsung9>
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

On Wed, Mar 16, 2016 at 11:23:14AM -0700, Stephen Hemminger wrote:
> On Tue, 15 Mar 2016 17:04:12 -0400
> Aaron Conole <aconole@redhat.com> wrote:
> 
> > --- a/include/uapi/linux/virtio_net.h
> > +++ b/include/uapi/linux/virtio_net.h
> > @@ -55,6 +55,7 @@
> >  #define VIRTIO_NET_F_MQ	22	/* Device supports Receive Flow
> >  					 * Steering */
> >  #define VIRTIO_NET_F_CTRL_MAC_ADDR 23	/* Set MAC address */
> > +#define VIRTIO_NET_F_MTU 25	/* Device supports Default MTU Negotiation */
> >  
> >  #ifndef VIRTIO_NET_NO_LEGACY
> >  #define VIRTIO_NET_F_GSO	6	/* Host handles pkts w/ any GSO type */
> > @@ -73,6 +74,8 @@ struct virtio_net_config {
> >  	 * Legal values are between 1 and 0x8000
> >  	 */
> >  	__u16 max_virtqueue_pairs;
> > +	/* Default maximum transmit unit advice */
> > +	__u16 mtu;
> >  } __attribute__((packed));
> >  
> >  /*
> 
> You can't change user visible headers without breaking ABI.
> This structure might be used by other user code.

Then this userspace is broken.

If someone uses virtio code one has to follow virtio spec.

And Virtio spec makes it very clear that
1. config space size can change at any time
2. fields can only be accessed if the correct feature bit
   has been both advertized in host bitmap and acknowledged
   in guest bitmap

> Also how can this
> work if host is using old size of structure.

It works because access is guarded by feature bit check.

-- 
MST
