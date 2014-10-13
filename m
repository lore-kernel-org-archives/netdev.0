From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [PATCH v3 10/25] virtio: add API to enable VQs early
Date: Mon, 13 Oct 2014 17:22:39 +1030
Message-ID: <8738asea14.fsf@rustcorp.com.au>
References: <1413114332-626-1-git-send-email-mst@redhat.com>
	<1413114332-626-11-git-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linux-s390@vger.kernel.org, linux-scsi@vger.kernel.org, kvm@vger.kernel.org,
	Christian Borntraeger <borntraeger@de.ibm.com>, netdev@vger.kernel.org,
	virtualization@lists.linux-foundation.org,
	Paolo Bonzini <pbonzini@redhat.com>, Amit Shah <amit.shah@redhat.com>,
	v9fs-developer@lists.sourceforge.net,
	"David S. Miller" <davem@davemloft.net>
To: "Michael S. Tsirkin" <mst@redhat.com>, linux-kernel@vger.kernel.org
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1413114332-626-11-git-send-email-mst@redhat.com>
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

"Michael S. Tsirkin" <mst@redhat.com> writes:
> virtio spec 0.9.X requires DRIVER_OK to be set before
> VQs are used, but some drivers use VQs before probe
> function returns.
> Since DRIVER_OK is set after probe, this violates the spec.
>
> Even though under virtio 1.0 transitional devices support this
> behaviour, we want to make it possible for those early callers to become
> spec compliant and eventually support non-transitional devices.
>
> Add API for drivers to call before using VQs.
>
> Sets DRIVER_OK internally.
>
> Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
> Reviewed-by: Cornelia Huck <cornelia.huck@de.ibm.com>

OK, this all looks good, but I think we should do two things:

1) rename virtio_enable_vqs_early() to virtio_device_ready().
2) Add a BUG_ON in the virtio_ring code to make sure device is ready
   before any ops are called.

Cheers,
Rusty.
