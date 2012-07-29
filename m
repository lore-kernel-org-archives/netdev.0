From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [net-next RFC V5 4/5] virtio_net: multiqueue support
Date: Sun, 29 Jul 2012 12:50:21 +0300
Message-ID: <20120729095021.GC8977@redhat.com>
References: <1341484194-8108-1-git-send-email-jasowang@redhat.com>
	<1341484194-8108-5-git-send-email-jasowang@redhat.com>
	<20120720134014.GD16550@redhat.com> <500CE5B3.3040404@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: krkumar2@in.ibm.com, habanero@linux.vnet.ibm.com, mashirle@us.ibm.com,
	kvm@vger.kernel.org, netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org, edumazet@google.com,
	tahm@linux.vnet.ibm.com, jwhan@filewood.snu.ac.kr,
	davem@davemloft.net, sri@us.ibm.com
To: Jason Wang <jasowang@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <500CE5B3.3040404@redhat.com>
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

On Mon, Jul 23, 2012 at 01:48:35PM +0800, Jason Wang wrote:
> >>+	}
> >>
> >>-	if (virtio_has_feature(vi->vdev, VIRTIO_NET_F_CTRL_VQ)) {
> >>+	ret = vi->vdev->config->find_vqs(vi->vdev, total_vqs, vqs, callbacks,
> >>+					 (const char **)names);
> >>+	if (ret)
> >>+		goto err;
> >>+
> >>+	if (vi->has_cvq)
> >>  		vi->cvq = vqs[2];
> >>
> >>-		if (virtio_has_feature(vi->vdev, VIRTIO_NET_F_CTRL_VLAN))
> >>-			vi->dev->features |= NETIF_F_HW_VLAN_FILTER;
> >>+	for (i = 0; i<  vi->num_queue_pairs * 2; i += 2) {
> >>+		int j = i == 0 ? i : i + vi->has_cvq;
> >>+		vi->rq[i / 2]->vq = vqs[j];
> >>+		vi->sq[i / 2]->vq = vqs[j + 1];
> >Same here.
> 
> Consider the code is really simple, seem no need to use helpers.

Well it was not simple to at least one reader :)
The problem is not this logic is complex,
it is that it is spread all over the code.

If we had e.g. vnet_tx_vqn_to_queuenum vnet_tx_queuenum_to_vqn
and same for rx, then the logic would all be
in one place, and have a tidy comment on top explaining
the VQ numbering scheme.

-- 
MST
