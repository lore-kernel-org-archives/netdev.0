From: George Zhang <georgezhang@vmware.com>
Subject: [PATCH 0/6] VSOCK for Linux upstreaming
Date: Tue, 08 Jan 2013 15:59:08 -0800
Message-ID: <20130108235633.3719.6085.stgit@promb-2n-dhcp175.eng.vmware.com>
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
VMware to address Greg's and all other's code review comments.

Summary of changes:
        - Rebase our linux kernel tree from v3.5 to v3.7.
        - Fix all checkpatch warnings and errors. Fix some checkpatch with -strict
          errors.

              This addresses Greg's comment: On 15 Nov 2012 15:47:14 -0800
              Re: [PATCH 07/12] VMCI: queue pairs implementation.
              chckpatch sanity checking.
        - Fix vmci_get_contextid naming error.
        - Remove ASSERT/BUG_ON for vmci and vsock source codes.

              This addresses ddress Greg's comment on On 15 Nov 2012 15:47:14 -0800
              Re: [PATCH 02/12] VMCI: datagram implementation.
              Remove all BUG_ON(), asserts.
        - use standard Linux kernel ioctl interface.

              This addresses Greg's comment on On Thu, 15 Nov 2012 16:01:18 -0800
              Re: [PATCH 12/12] VMCI: Some header and config files.
              use linux in-kernel IO macros for VMCI.
        - Add vmci ioctl code entry in ioctl-number.txt.
        - Remove printk from header file. Align properly for macro PCI_VENDOR_ID_VMWARE.
          Remove #define for VMCI_DRIVER_VERSION_STRING.
          Remove #define for MODULE_NAME.
          Remove #define for pr_fmt and #define ASSERT(x).
          Remove inline function VMCI_MAKE_HANDLE and vmci_make_handle which return a
              structure on stack. use macro instead and use C99 initialization.
          Remove #define for VMCI_HANDLE_TO_CONTEXT_ID and VMCI_HANDLE_TO_RESOURCE_ID
          Change macro to inline function for VMCI_HANDLE_EQUAL.
          Remove u32 typedefs for vmci_id, vmci_event, vmci_privilege_flags.
          Use C99 style initialization for struct VMCI_INVALID_HANDLE.
          Use inline function instead of macro for VMCI_HANDLE_INVALID.
          No change for vmw_vmci_api.h location (under include/linux/ directory).
          No change for macros VMCI_CONTEXT_IS_VM, VMCI_HOST_CONTEXT_ID,
              VMCI_RESERVED_CID_LIMIT, VMCI_HYPERVISOR_CONTEXT_ID and
              VMCI_WELL_KNOWN_CONTEXT_ID. Still in header file include/linux/vmw_vmci_defs.h

              This addresses Greg's several comments on Thu, 15 Nov 2012 16:01:18 -0800
              Re: [PATCH 12/12] VMCI: Some header and config files.


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


 Documentation/ioctl/ioctl-number.txt |    1 
 include/linux/socket.h               |    4 
 net/Kconfig                          |    1 
 net/Makefile                         |    1 
 net/vmw_vsock/Kconfig                |   14 
 net/vmw_vsock/Makefile               |    4 
 net/vmw_vsock/af_vsock.c             | 3279 ++++++++++++++++++++++++++++++++++
 net/vmw_vsock/af_vsock.h             |  173 ++
 net/vmw_vsock/notify.c               |  675 +++++++
 net/vmw_vsock/notify.h               |  124 +
 net/vmw_vsock/notify_qstate.c        |  408 ++++
 net/vmw_vsock/stats.c                |   30 
 net/vmw_vsock/stats.h                |  150 ++
 net/vmw_vsock/util.c                 |  345 ++++
 net/vmw_vsock/util.h                 |  187 ++
 net/vmw_vsock/vmci_sockets.h         |  270 +++
 net/vmw_vsock/vmci_sockets_packet.h  |   79 +
 net/vmw_vsock/vsock_addr.c           |  116 +
 net/vmw_vsock/vsock_addr.h           |   34 
 net/vmw_vsock/vsock_common.h         |  103 +
 net/vmw_vsock/vsock_packet.h         |   92 +
 net/vmw_vsock/vsock_version.h        |   22 
 22 files changed, 6111 insertions(+), 1 deletions(-)
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
