From: acking@vmware.com
Subject: [PATCH 0/1] VM Sockets for Linux upstreaming
Date: Fri, 25 Jan 2013 09:37:49 -0800
Message-ID: <1359135470-30677-1-git-send-email-acking@vmware.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: pv-drivers@vmware.com, gregkh@linuxfoundation.org, acking@vmware.com,
	davem@davemloft.net
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org
Return-path: <virtualization-bounces@lists.linux-foundation.org>
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

From: Andy King <acking@vmware.com>

** Introduce VM Sockets ***

In an effort to improve the out-of-the-box experience with Linux kernels for
VMware users, VMware is working on readying the VM Sockets (VSOCK, formerly
VMCI Sockets) (vmw_vsock) kernel module for inclusion in the Linux kernel. The
purpose of this post is to acquire feedback on the vmw_vsock kernel module.

Unlike previous submissions, where the new socket family was entirely reliant
on VMware's VMCI PCI device (and thus VMware's hypervisor), VM Sockets is now
_mostly_ separated out into two parts:

o Core socket code, which is transport-neutral and invokes transport
  callbacks to communicate with the hypervisor.
o A VMCI transport, which communicates over VMCI with the VMware hypervisor.

This should provide a path to introducing additional transports, for example
virtio, with the ultimate goal being to make this new socket family
hypervisor-neutral.

Andy King (1):
  VSOCK: Introduce VM Sockets

 include/linux/socket.h                       |    4 +-
 include/uapi/linux/vm_sockets.h              |  169 +++
 net/Kconfig                                  |    1 +
 net/Makefile                                 |    1 +
 net/vmw_vsock/Kconfig                        |   14 +
 net/vmw_vsock/Makefile                       |    4 +
 net/vmw_vsock/af_vsock.c                     | 1983 ++++++++++++++++++++++++++
 net/vmw_vsock/af_vsock.h                     |  256 ++++
 net/vmw_vsock/vmci_transport.c               | 1863 ++++++++++++++++++++++++
 net/vmw_vsock/vmci_transport.h               |   90 ++
 net/vmw_vsock/vmci_transport_notify.c        |  677 +++++++++
 net/vmw_vsock/vmci_transport_notify.h        |  126 ++
 net/vmw_vsock/vmci_transport_notify_qstate.c |  411 ++++++
 net/vmw_vsock/vsock_addr.c                   |  118 ++
 net/vmw_vsock/vsock_addr.h                   |   36 +
 net/vmw_vsock/vsock_version.h                |   22 +
 16 files changed, 5774 insertions(+), 1 deletions(-)
 create mode 100644 include/uapi/linux/vm_sockets.h
 create mode 100644 net/vmw_vsock/Kconfig
 create mode 100644 net/vmw_vsock/Makefile
 create mode 100644 net/vmw_vsock/af_vsock.c
 create mode 100644 net/vmw_vsock/af_vsock.h
 create mode 100644 net/vmw_vsock/vmci_transport.c
 create mode 100644 net/vmw_vsock/vmci_transport.h
 create mode 100644 net/vmw_vsock/vmci_transport_notify.c
 create mode 100644 net/vmw_vsock/vmci_transport_notify.h
 create mode 100644 net/vmw_vsock/vmci_transport_notify_qstate.c
 create mode 100644 net/vmw_vsock/vsock_addr.c
 create mode 100644 net/vmw_vsock/vsock_addr.h
 create mode 100644 net/vmw_vsock/vsock_version.h

-- 
1.7.4.1
