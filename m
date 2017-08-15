From: Dexuan Cui <decui@microsoft.com>
Subject: [PATCH net-next 0/3] add Hyper-V transport for Virtual Sockets
Date: Tue, 15 Aug 2017 22:02:46 +0000
Message-ID: <KL1P15301MB0008660CC5FF0CF8FC169CC1BF8D0@KL1P15301MB0008.APCP153.PROD.OUTLOOK.COM>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: "'gregkh@linuxfoundation.org'" <'gregkh@linuxfoundation.org'>,
        "KY Srinivasan" <kys@microsoft.com>,
        Haiyang Zhang <haiyangz@microsoft.com>,
        Stephen Hemminger <sthemmin@microsoft.com>,
        Andy King <acking@vmware.com>,
        Dmitry Torokhov <dtor@vmware.com>,
        George Zhang <georgezhang@vmware.com>,
        Jorgen Hansen <jhansen@vmware.com>,
        Reilly Grant <grantr@vmware.com>,
        "Michal Kubecek" <mkubecek@suse.cz>, Asias He <asias@redhat.com>,
        Stefan Hajnoczi <stefanha@redhat.com>,
        Vitaly Kuznetsov <vkuznets@redhat.com>,
        Cathy Avery <cavery@redhat.com>,
        "jasowang@redhat.com" <jasowang@redhat.com>,
        "Rolf Neugebauer" <rolf.neugebauer@docker.com>,
        Dave Scott <dave.scott@docker.com>,
        Marcelo Cerri <marcelo.cerri@canonical.com>,
        "apw@canonical.com" <apw@canonical.com>,
To: "davem@davemloft.net" <davem@davemloft.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Hyper-V Sockets (hv_sock) supplies a byte-stream based communication
mechanism between the host and the guest. It uses VMBus ringbuffer as the
transportation layer.

PATCH 01 and 02 are for VMCI and the common infrastructure vsock.

PATCH 03 implements the necessary support in Linux guest by introducing a
new vsock transport for AF_VSOCK.

Please review them.

Note: there are some other supporting fixes in the VMBus driver. I'll
post them separately for the char-misc tree.


PS, there was an old implementation of Hyper-V Sockets posted last year:
https://patchwork.kernel.org/patch/9244467/, which was not accepted. The
biggest challenge was that why Hyper-V Sockets required a new address
family, and I explained that was because of its different end point format.

Compared to the old implementation, this new implementation maps Hyper-V
Sockets end point format <GUID VmID, GUID ServiceID> to vsock's
<int cid, int port>, and hence it manages to share the common vsock
infrastructure to greatly reduce duplicate code, and avoid adding a new
address family. The details are documented in PATCH 03.

Dexuan Cui (3):
  VMCI: only load on VMware hypervisor
  vsock: fix vsock_dequeue/enqueue_accept race
  hv_sock: implements Hyper-V transport for Virtual Sockets (AF_VSOCK)

 MAINTAINERS                         |   1 +
 drivers/misc/vmw_vmci/vmci_driver.c |   8 +
 net/vmw_vsock/Kconfig               |  12 +
 net/vmw_vsock/Makefile              |   3 +
 net/vmw_vsock/af_vsock.c            |   7 +
 net/vmw_vsock/hyperv_transport.c    | 890 ++++++++++++++++++++++++++++++++=
++++
 6 files changed, 921 insertions(+)
 create mode 100644 net/vmw_vsock/hyperv_transport.c

--=20
2.7.4
