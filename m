From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH v6 34/46] virtio_net: disable mac write for virtio 1.0
Date: Sat, 29 Nov 2014 19:28:04 +0200
Message-ID: <20141129172804.GD22746@redhat.com>
References: <1417118789-18231-1-git-send-email-mst@redhat.com>
	<1417118789-18231-35-git-send-email-mst@redhat.com>
	<1417164024.5822.11@smtp.corp.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: thuth@linux.vnet.ibm.com, rusty@au1.ibm.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org,
	dahi@linux.vnet.ibm.com, pbonzini@redhat.com,
	David Miller <davem@davemloft.net>
To: Jason Wang <jasowang@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <1417164024.5822.11@smtp.corp.redhat.com>
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

On Fri, Nov 28, 2014 at 08:48:24AM +0008, Jason Wang wrote:
> 
> 
> On Fri, Nov 28, 2014 at 4:10 AM, Michael S. Tsirkin <mst@redhat.com> wrote:
> >The spec states that mac in config space is only driver-writable in the
> >legacy case.  Fence writing it in virtnet_set_mac_address() in the
> >virtio 1.0 case.
> >
> >Suggested-by: Cornelia Huck <cornelia.huck@de.ibm.com>
> >Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
> >---
> > drivers/net/virtio_net.c | 3 ++-
> > 1 file changed, 2 insertions(+), 1 deletion(-)
> >
> >diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
> >index c6a72d3..9ab3c50 100644
> >--- a/drivers/net/virtio_net.c
> >+++ b/drivers/net/virtio_net.c
> >@@ -1030,7 +1030,8 @@ static int virtnet_set_mac_address(struct net_device
> >*dev, void *p)
> > 				 "Failed to set mac address by vq command.\n");
> > 			return -EINVAL;
> > 		}
> >-	} else if (virtio_has_feature(vdev, VIRTIO_NET_F_MAC)) {
> >+	} else if (virtio_has_feature(vdev, VIRTIO_NET_F_MAC) &&
> >+		   !virtio_has_feature(vdev, VIRTIO_F_VERSION_1)) {
> > 		unsigned int i;
> > 		/* Naturally, this has an atomicity problem. */
> >-- 
> >MST
> 
> Does this mean there's no way to setting mac addres
> if ctrl mac addr is disabled in virtio-1?

More exactly: no way for host to know the guest mac address.

> If yes, we'd better keep this compatibility somehow.

If host wants to be notified about guest mac updates,
it must enable the appropriate ctrl command.
Or if it's an old host, it just doesn't enable virtio-1.

There's no way around this - it's in the spec.


-- 
MST
