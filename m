From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [RFC v2 -next 1/2] virtio: Start feature MTU support
Date: Thu, 17 Mar 2016 15:04:59 -0700
Message-ID: <20160317150459.49bf5c9b@samsung9>
References: <1458075853-14789-1-git-send-email-aconole@redhat.com>
	<1458075853-14789-2-git-send-email-aconole@redhat.com>
	<20160316112314.4510d386@samsung9> <f7tfuvox128.fsf@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, virtualization@lists.linux-foundation.org,
	linux-kernel@vger.kernel.org, "Michael S. Tsirkin" <mst@redhat.com>
To: Aaron Conole <aconole@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <f7tfuvox128.fsf@redhat.com>
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

On Thu, 17 Mar 2016 17:10:55 -0400
Aaron Conole <aconole@redhat.com> wrote:

> Stephen Hemminger <stephen@networkplumber.org> writes:
> 
> > On Tue, 15 Mar 2016 17:04:12 -0400
> > Aaron Conole <aconole@redhat.com> wrote:
> >
> >> --- a/include/uapi/linux/virtio_net.h
> >> +++ b/include/uapi/linux/virtio_net.h
> >> @@ -55,6 +55,7 @@
> >>  #define VIRTIO_NET_F_MQ	22	/* Device supports Receive Flow
> >>  					 * Steering */
> >>  #define VIRTIO_NET_F_CTRL_MAC_ADDR 23	/* Set MAC address */
> >> +#define VIRTIO_NET_F_MTU 25	/* Device supports Default MTU Negotiation */
> >>  
> >>  #ifndef VIRTIO_NET_NO_LEGACY
> >>  #define VIRTIO_NET_F_GSO	6	/* Host handles pkts w/ any GSO type */
> >> @@ -73,6 +74,8 @@ struct virtio_net_config {
> >>  	 * Legal values are between 1 and 0x8000
> >>  	 */
> >>  	__u16 max_virtqueue_pairs;
> >> +	/* Default maximum transmit unit advice */
> >> +	__u16 mtu;
> >>  } __attribute__((packed));
> >>  
> >>  /*
> >
> > You can't change user visible headers without breaking ABI.
> > This structure might be used by other user code. Also how can this
> > work if host is using old size of structure.
> 
> How else can this field be added and remain compliant with the spec? The
> spec requires that mtu be passed in the virtio_net_config field.
> 
> As for old sizeof, I think the absence of the VIRTIO_NET_F_MTU bit being
> asserted is confirmation that mtu is not valid (at least, it is implied
> in the spec).

Michael is right as long as the code checks for MTU flag before
referencing the mtu field, everything is fine.  Actually, the structure
is never used directly only by fetching fields with offsetof
