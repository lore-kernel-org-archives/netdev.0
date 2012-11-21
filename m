From: George Zhang <georgezhang@vmware.com>
Subject: [PATCH 0/6] VSOCK for Linux upstreaming
Date: Wed, 21 Nov 2012 12:39:11 -0800
Message-ID: <20121121203715.14395.27632.stgit@promb-2n-dhcp175.eng.vmware.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: pv-drivers@vmware.com, gregkh@linuxfoundation.org, davem@davemloft.net
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	georgezhang@vmware.com, virtualization@lists.linux-foundation.org
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


* * *
This series of VSOCK linux upstreaming patches include latest udpate from
VMware.

Summary of changes:
        - Sparse clean.
        - Checkpatch clean with one exception, a "complex macro" in
          which we can't add parentheses.
        - Remove all runtime assertions.
        - Fix device name, so that existing user clients work.
        - Fix VMCI handle lookup.

* * *

In an effort to improve the out-of-the-box experience with Linux
kernels for VMware users, VMware is working on readying the Virtual
Machine Communication Interface (vmw_vmci) and VMCI Sockets (VSOCK)
(vmw_vsock) kernel modules for inclusion in the Linux kernel. The
purpose of this post is to acquire feedback on the vmw_vsock kernel
module. The vmw_vmci kernel module has been presented in an early post.


* * *

VMCI Sockets allows virtual machines to communicate with host kernel
modules and the VMware hypervisors. VMCI Sockets kernel module has
dependency on VMCI kernel module. User level applications both in
a virtual machine and on the host can use vmw_vmci through VMCI
Sockets API which facilitates fast and efficient communication
between guest virtual machines and their host. A socket
address family designed to be compatible with UDP and TCP at the
interface level. Today, VMCI and VMCI Sockets are used by the VMware
shared folders (HGFS) and various VMware Tools components inside the
guest for zero-config, network-less access to VMware host services. In
addition to this, VMware's users are using VMCI Sockets for various
applications, where network access of the virtual machine is
restricted or non-existent. Examples of this are VMs communicating
with device proxies for proprietary hardware running as host
applications and automated testing of applications running within
virtual machines.

The VMware VMCI Sockets are similar to other socket types, like
Berkeley UNIX socket interface. The VMCI sockets module supports
both connection-oriented stream sockets like TCP, and connectionless
datagram sockets like UDP. The VSOCK protocol family is defined as
"AF_VSOCK" and the socket operations split for SOCK_DGRAM and
SOCK_STREAM.

For additional information about the use of VMCI and in particular
VMCI Sockets, please refer to the VMCI Socket Programming Guide
available at https://www.vmware.com/support/developer/vmci-sdk/.



---

George Zhang (6):
      VSOCK: vsock protocol implementation.
      VSOCK: vsock address implementaion.
      VSOCK: notification implementation.
      VSOCK: statistics implementation.
      VSOCK: utility functions.
      VSOCK: header and config files.


 include/linux/socket.h              |    4 
 net/Kconfig                         |    1 
 net/Makefile                        |    1 
 net/vmw_vsock/Kconfig               |   14 
 net/vmw_vsock/Makefile              |    4 
 net/vmw_vsock/af_vsock.c            | 4054 +++++++++++++++++++++++++++++++++++
 net/vmw_vsock/af_vsock.h            |  180 ++
 net/vmw_vsock/notify.c              |  983 ++++++++
 net/vmw_vsock/notify.h              |  130 +
 net/vmw_vsock/notify_qstate.c       |  625 +++++
 net/vmw_vsock/stats.c               |   37 
 net/vmw_vsock/stats.h               |  217 ++
 net/vmw_vsock/util.c                |  620 +++++
 net/vmw_vsock/util.h                |  314 +++
 net/vmw_vsock/vmci_sockets.h        |  517 ++++
 net/vmw_vsock/vmci_sockets_packet.h |   90 +
 net/vmw_vsock/vsock_addr.c          |  246 ++
 net/vmw_vsock/vsock_addr.h          |   40 
 net/vmw_vsock/vsock_common.h        |  127 +
 net/vmw_vsock/vsock_packet.h        |  124 +
 net/vmw_vsock/vsock_version.h       |   28 
 21 files changed, 8355 insertions(+), 1 deletions(-)
 create mode 100644 net/vmw_vsock/Kconfig
 create mode 100644 net/vmw_vsock/Makefile
 create mode 100644 net/vmw_vsock/af_vsock.c
 create mode 100644 net/vmw_vsock/af_vsock.h
 create mode 100644 net/vmw_vsock/notify.c
 create mode 100644 net/vmw_vsock/notify.h
 create mode 100644 net/vmw_vsock/notify_qstate.c
 create mode 100644 net/vmw_vsock/stats.c
 create mode 100644 net/vmw_vsock/stats.h
 create mode 100644 net/vmw_vsock/util.c
 create mode 100644 net/vmw_vsock/util.h
 create mode 100644 net/vmw_vsock/vmci_sockets.h
 create mode 100644 net/vmw_vsock/vmci_sockets_packet.h
 create mode 100644 net/vmw_vsock/vsock_addr.c
 create mode 100644 net/vmw_vsock/vsock_addr.h
 create mode 100644 net/vmw_vsock/vsock_common.h
 create mode 100644 net/vmw_vsock/vsock_packet.h
 create mode 100644 net/vmw_vsock/vsock_version.h

-- 
Signature
