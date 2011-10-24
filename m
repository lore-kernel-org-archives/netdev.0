From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [RFC v2 PATCH 5/4 PATCH] virtio-net: send
	gratuitous packet when needed
Date: Mon, 24 Oct 2011 14:54:59 +1030
Message-ID: <87ty6z10f8.fsf@rustcorp.com.au>
References: <20111022054311.21798.3340.stgit@dhcp-8-146.nay.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: pbonzini@redhat.com, kvm@vger.kernel.org, netdev@vger.kernel.org
To: Jason Wang <jasowang@redhat.com>, aliguori@us.ibm.com, quintela@redhat.com,
	jan.kiszka@siemens.com, mst@redhat.com, qemu-devel@nongnu.org,
	blauwirbel@gmail.com
Return-path: <qemu-devel-bounces+gceq-qemu-devel=gmane.org@nongnu.org>
In-Reply-To: <20111022054311.21798.3340.stgit@dhcp-8-146.nay.redhat.com>
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

On Sat, 22 Oct 2011 13:43:11 +0800, Jason Wang <jasowang@redhat.com> wrote:
> This make let virtio-net driver can send gratituous packet by a new
> config bit - VIRTIO_NET_S_ANNOUNCE in each config update
> interrupt. When this bit is set by backend, the driver would schedule
> a workqueue to send gratituous packet through NETDEV_NOTIFY_PEERS.
> 
> This feature is negotiated through bit VIRTIO_NET_F_GUEST_ANNOUNCE.
> 
> Signed-off-by: Jason Wang <jasowang@redhat.com>

This seems like a huge layering violation.  Imagine this in real
hardware, for example.

There may be a good reason why virtual devices might want this kind of
reconfiguration cheat, which is unnecessary for normal machines, but
it'd have to be spelled out clearly in the spec to justify it...

Cheers,
Rusty.
