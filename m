From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [virtio-spec: RFC PATCH] virtio-spec: introduce
	VIRTIO_NET_F_GUEST_ANNOUNCE
Date: Thu, 27 Oct 2011 12:02:32 +1030
Message-ID: <8739efnrrj.fsf@rustcorp.com.au>
References: <20111026084912.19391.26534.stgit@dhcp-8-146.nay.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: Jason Wang <jasowang@redhat.com>, netdev@vger.kernel.org,
	qemu-devel@nongnu.org, kvm@vger.kernel.org, mst@redhat.com
Return-path: <qemu-devel-bounces+gceq-qemu-devel=gmane.org@nongnu.org>
In-Reply-To: <20111026084912.19391.26534.stgit@dhcp-8-146.nay.redhat.com>
List-Unsubscribe: <https://lists.nongnu.org/mailman/options/qemu-devel>,
	<mailto:qemu-devel-request@nongnu.org?subject=unsubscribe>
List-Archive: <http://lists.nongnu.org/archive/html/qemu-devel>
List-Post: <mailto:qemu-devel@nongnu.org>
List-Help: <mailto:qemu-devel-request@nongnu.org?subject=help>
List-Subscribe: <https://lists.nongnu.org/mailman/listinfo/qemu-devel>,
	<mailto:qemu-devel-request@nongnu.org?subject=subscribe>
Errors-To: qemu-devel-bounces+gceq-qemu-devel=gmane.org@nongnu.org
Sender: qemu-devel-bounces+gceq-qemu-devel=gmane.org@nongnu.org
List-Id: netdev.vger.kernel.org

On Wed, 26 Oct 2011 16:49:12 +0800, Jason Wang <jasowang@redhat.com> wrote:
> Network connections in guest need to be kept after migration. This is done by
> sending gratuitous packet and let switch learn new port of the mac
> address. As hypervisor does not have the knowledge of guest network
> configurations such as tagged vlan or ipv6, it may require guest to send
> gratuitous packet.
> 
> This patch introduces a new feature bit of virtio network adapter -
> VIRTIO_NET_F_GUEST_ANNOUNCE which is used to indicate the ability to send
> gratuitous packets by guest. A new status bit - VIRTIO_NET_S_ANNOUNCE is also
> introduced to notify the guest the need for sending gratuitous packet. When
> guest notice this, it should clear it and send the gratuitous packet.
> 
> Signed-off-by: Jason Wang <jasowang@redhat.com>

Thanks!  I applied it manually, since you didn't enable change tracking
in LyX (I like to produce a PDF showing changes between versions).

Some minor cleanups, here's the main text below.

Cheers,
Rusty.

Gratuitous Packet Sending

If the driver negotiates the VIRTIO_NET_F_GUEST_ANNOUNCE, it can ask the guest to send gratuitous packets; this is usually done after the guest has been physically migrated, and needs to announce its presence on the new network links. (As hypervisor does not have the knowledge of guest network configuration (eg. tagged vlan) it is simplest to prod the guest in this way).

The Guest needs to check VIRTIO_NET_S_ANNOUNCE bit in status field when it notices the changes of device configuration.

Processing this notification involves:

Clearing VIRTIO_NET_S_ANNOUNCE bit in the status field.

Sending the gratuitous packets. 
