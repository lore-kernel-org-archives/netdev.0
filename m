From: Stefan Hajnoczi <stefanha@redhat.com>
Subject: [PATCH 0/6] VSOCK: revert virtio-vsock until device spec is finalized
Date: Tue,  8 Dec 2015 19:57:30 +0800
Message-ID: <1449575856-28507-1-git-send-email-stefanha@redhat.com>
Cc: Matt Benjamin <mbenjamin@redhat.com>,
	"David S. Miller" <davem@davemloft.net>, kvm@vger.kernel.org,
	Christoffer Dall <christoffer.dall@linaro.org>,
	"Michael S. Tsirkin" <mst@redhat.com>,
	virtualization@lists.linux-foundation.org, matt.ma@linaro.org,
	Stefan Hajnoczi <stefanha@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:56857 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752092AbbLHL5m (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Dec 2015 06:57:42 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The virtio-vsock device specification is not finalized yet.  Michael Tsirkin
voiced concerned about merging this code when the hardware interface (and
possibly the userspace interface) could still change.

Please revert for now.

I am working to finalize the virtio-vsock device specification and at that
point the interfaces will be stable.

Stefan Hajnoczi (6):
  Revert "VSOCK: fix returnvar.cocci warnings"
  Revert "VSOCK: Add Makefile and Kconfig"
  Revert "VSOCK: Introduce vhost-vsock.ko"
  Revert "VSOCK: Introduce virtio-vsock.ko"
  Revert "VSOCK: Introduce virtio-vsock-common.ko"
  Revert "VSOCK: Introduce vsock_find_unbound_socket and
    vsock_bind_dgram_generic"

 drivers/vhost/Kconfig                   |    4 -
 drivers/vhost/Kconfig.vsock             |    7 -
 drivers/vhost/Makefile                  |    4 -
 drivers/vhost/vsock.c                   |  630 ---------------
 drivers/vhost/vsock.h                   |    4 -
 include/linux/virtio_vsock.h            |  209 -----
 include/net/af_vsock.h                  |    2 -
 include/uapi/linux/virtio_ids.h         |    1 -
 include/uapi/linux/virtio_vsock.h       |   89 ---
 net/vmw_vsock/Kconfig                   |   18 -
 net/vmw_vsock/Makefile                  |    2 -
 net/vmw_vsock/af_vsock.c                |   70 --
 net/vmw_vsock/virtio_transport.c        |  466 -----------
 net/vmw_vsock/virtio_transport_common.c | 1272 -------------------------------
 14 files changed, 2778 deletions(-)
 delete mode 100644 drivers/vhost/Kconfig.vsock
 delete mode 100644 drivers/vhost/vsock.c
 delete mode 100644 drivers/vhost/vsock.h
 delete mode 100644 include/linux/virtio_vsock.h
 delete mode 100644 include/uapi/linux/virtio_vsock.h
 delete mode 100644 net/vmw_vsock/virtio_transport.c
 delete mode 100644 net/vmw_vsock/virtio_transport_common.c

-- 
2.5.0
