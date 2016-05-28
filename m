From: ggarcia@abra.uab.cat
Subject: [RFC 0/3] vsockmon: virtual device to monitor AF_VSOCK sockets.
Date: Sat, 28 May 2016 18:29:04 +0200
Message-ID: <20160528162907.14809-1-ggarcia@deic.uab.cat>
Content-Transfer-Encoding: 7BIT
Cc: jhansen@vmware.com, stefanha@redhat.com,
	Gerard Garcia <ggarcia@abra.uab.cat>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from damascus.uab.es ([158.109.168.135]:19939 "EHLO damascus.uab.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750738AbcE1R3T (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 28 May 2016 13:29:19 -0400
Received: from damascus.uab.es ([127.0.0.1])
 by damascus.uab.es (Sun Java System Messaging Server 6.1 HotFix 0.10 (built
 Jan  6 2005)) with ESMTP id <0O7W00JQ7B4RILR0@damascus.uab.es> for
 netdev@vger.kernel.org; Sat, 28 May 2016 18:29:15 +0200 (CEST)
Received: from abra.uab.es ([158.109.79.4])
 by damascus.uab.es (Sun Java System Messaging Server 6.1 HotFix 0.10 (built
 Jan  6 2005)) with ESMTP id <0O7W00JVRB4QXQO0@damascus.uab.es> for
 netdev@vger.kernel.org; Sat, 28 May 2016 18:29:14 +0200 (CEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gerard Garcia <ggarcia@deic.uab.cat>

Virtual socket transports operate at kernel level therefore, there is no easy way to see the traffic exchanged between virtual machines and hypervisors that communicate using AF_VSOCK sockets. In addition, being able to see the control messages exchanged by the transports may be useful for debugging and optimization purposes. This patch adds a virtual device that may be used to see the traffic exchanged between virtual machines and hypervisors through AF_VSOCK sockets.

Its structure is based on the nlmon device and this version just targets the virtio transport, but support for the VMCI transport can be easily implemented. The vsockmon header consists of two structs: a generic header and a header specific to the transport. The generic header allows to follow an AF_VSOCK stream without having to understand the details of the transport while the transport header gives more detail which may be useful for troubleshooting and debugging.

The repository https://github.com/GerardGarcia/linux/tree/vsockmon implements these patches over the Stefan Hajnoczi vsock-next repository https://github.com/stefanha/linux/tree/vsock-next where the virtio trasnport is implemented. In the repository there is also a simple program that shows the traffic from a vsockmon device: https://github.com/GerardGarcia/linux/blob/vsockmon/vsockmon.c that can be used for testing.

Any thoughts and comments will be greatly appreciated.

Thanks to Stefan Hajnoczi for his help.

Gerard

Gerard Garcia (3):
  vsockmon: Add tap functions.
  vsockmon: Add vsockmon device
  vsockmon: Add vsock hooks

 drivers/net/Kconfig           |   8 ++
 drivers/net/Makefile          |   1 +
 drivers/net/vsockmon.c        | 171 ++++++++++++++++++++++++++++++++++++++++++
 drivers/vhost/vsock.c         |  71 ++++++++++++++++++
 include/net/af_vsock.h        |  13 ++++
 include/uapi/linux/Kbuild     |   1 +
 include/uapi/linux/if_arp.h   |   1 +
 include/uapi/linux/vsockmon.h |  37 +++++++++
 net/vmw_vsock/af_vsock.c      | 105 ++++++++++++++++++++++++++
 9 files changed, 408 insertions(+)
 create mode 100644 drivers/net/vsockmon.c
 create mode 100644 include/uapi/linux/vsockmon.h

-- 
2.8.3
