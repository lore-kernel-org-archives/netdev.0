From: Jason Wang <jasowang@redhat.com>
Subject: [RFC PATCH 0/2] Multiqueue support for qemu(virtio-net)
Date: Thu, 28 Apr 2011 11:11:41 +0800
Message-ID: <19896.56045.886758.739747@gargle.gargle.HOWL>
References: <20110420082706.32157.59668.stgit@dhcp-91-7.nay.redhat.com.englab.nay.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: krkumar2@in.ibm.com, kvm@vger.kernel.org, mst@redhat.com,
	netdev@vger.kernel.org, rusty@rustcorp.com.au, qemu-devel@nongnu.org
To: anthony@codemonkey.ws
Return-path: <qemu-devel-bounces+gceq-qemu-devel=gmane.org@nongnu.org>
In-Reply-To: <20110420082706.32157.59668.stgit@dhcp-91-7.nay.redhat.com.englab.nay.redhat.com>
List-Unsubscribe: <https://lists.nongnu.org/mailman/options/qemu-devel>,
	<mailto:qemu-devel-request@nongnu.org?subject=unsubscribe>
List-Archive: </archive/html/qemu-devel>
List-Post: <mailto:qemu-devel@nongnu.org>
List-Help: <mailto:qemu-devel-request@nongnu.org?subject=help>
List-Subscribe: <https://lists.nongnu.org/mailman/listinfo/qemu-devel>,
	<mailto:qemu-devel-request@nongnu.org?subject=subscribe>
Errors-To: qemu-devel-bounces+gceq-qemu-devel=gmane.org@nongnu.org
Sender: qemu-devel-bounces+gceq-qemu-devel=gmane.org@nongnu.org
List-Id: netdev.vger.kernel.org

Jason Wang writes:
 > Inspired by Krishna's patch (http://www.spinics.net/lists/kvm/msg52098.html) and
 > Michael's suggestions.  The following series adds the multiqueue support for
 > qemu and enable it for virtio-net (both userspace and vhost).
 > 
 > The aim for this series is to simplified the management and achieve the same
 > performacne with less codes.
 > 
 > Follows are the differences between this series and Krishna's:
 > 
 > - Add the multiqueue support for qemu and also for userspace virtio-net
 > - Instead of hacking the vhost module to manipulate kthreads, this patch just
 > implement the userspace based multiqueues and thus can re-use the existed vhost kernel-side codes without any modification.
 > - Use 1:1 mapping between TX/RX pairs and vhost kthread because the
 > implementation is based on usersapce.
 > - The cli is also changed to make the mgmt easier, the -netdev option of qdev
 > can now accpet more than one ids. You can start a multiqueue virtio-net device
 > through:
 > ./qemu-system-x86_64 -netdev tap,id=hn0,vhost=on,fd=X -netdev
 > tap,id=hn0,vhost=on,fd=Y -device virtio-net-pci,netdev=hn0#hn1,queues=2 ...
 > 

Hi anthony:

Have any comments about this series (cli, codes, ...)?

Thanks.

 > The series is very primitive and still need polished.
 > 
 > Suggestions are welcomed.
 > ---
 > 
 > Jason Wang (2):
 >       net: Add multiqueue support
 >       virtio-net: add multiqueue support
 > 
 > 
 >  hw/qdev-properties.c |   37 ++++-
 >  hw/qdev.h            |    3 
 >  hw/vhost.c           |   26 ++-
 >  hw/vhost.h           |    1 
 >  hw/vhost_net.c       |    7 +
 >  hw/vhost_net.h       |    2 
 >  hw/virtio-net.c      |  409 ++++++++++++++++++++++++++++++++------------------
 >  hw/virtio-net.h      |    2 
 >  hw/virtio-pci.c      |    1 
 >  hw/virtio.h          |    1 
 >  net.c                |   34 +++-
 >  net.h                |   15 +-
 >  12 files changed, 353 insertions(+), 185 deletions(-)
 > 
 > -- 
 > Jason Wang
 > --
 > To unsubscribe from this list: send the line "unsubscribe netdev" in
 > the body of a message to majordomo@vger.kernel.org
 > More majordomo info at  http://vger.kernel.org/majordomo-info.html
