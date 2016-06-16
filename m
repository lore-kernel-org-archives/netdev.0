From: Shrikrishna Khare <skhare@vmware.com>
Subject: [PATCH net-next v5 0/7] vmxnet3: upgrade to version 3
Date: Thu, 16 Jun 2016 10:51:52 -0700
Message-ID: <1466099519-39322-1-git-send-email-skhare@vmware.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Shrikrishna Khare <skhare@vmware.com>
To: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<pv-drivers@vmware.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

vmxnet3 emulation has recently added several new features which includes
support for new commands the driver can issue to emulation, change in
descriptor fields etc. This patch series extends the vmxnet3 driver to
leverage these new features.

Compatibility is maintained using existing vmxnet3 versioning mechanism as
follows:
 - new features added to vmxnet3 emulation are associated with new vmxnet3
   version viz. vmxnet3 version 3.
 - emulation advertises all the versions it supports to the driver.
 - during initialization, vmxnet3 driver picks the highest version number
 supported by both the emulation and the driver and configures emulation
 to run at that version.

In particular, following changes are introduced:

Patch 1:
  Some command definitions from previous vmxnet3 versions are
  missing. This patch adds those definitions before moving to vmxnet3
  version 3. It also fixes copyright info and maintained by.

Patch 2:
  This patch introduces generalized command interface which allows
  for easily adding new commands that vmxnet3 driver can issue to the
  emulation. Further patches in this series make use of this facility.

Patch 3:
  Transmit data ring buffer is used to copy packet headers or small
  packets. It is a fixed size buffer. This patch extends the driver to
  allow variable sized transmit data ring buffer.

Patch 4:
  This patch introduces receive data ring buffer - a set of small sized
  buffers that are always mapped by the emulation. This avoids memory
  mapping/unmapping overhead for small packets.

Patch 5:
  The vmxnet3 emulation supports a variety of coalescing modes. This patch
  extends vmxnet3 driver to allow querying and configuring these modes.

Patch 6:
  In vmxnet3 version 3, the emulation added support for the vmxnet3 driver
  to communicate information about the memory regions the driver will use
  for rx/tx buffers. This patch exposes related commands to the driver.

Patch 7:
  With all vmxnet3 version 3 changes incorporated in the vmxnet3 driver,
  with this patch, the driver can configure emulation to run at vmxnet3
  version 3.

Changes in v2:
 - v1 patch used special values of rx-usecs to differentiate between
 coalescing modes. v2 uses relevant fields in struct ethtool_coalesce
 to choose modes. Also, a new command VMXNET3_CMD_GET_COALESCE
 is introduced which allows driver to query the device for default
 coalescing configuration.

Changes in v3:
 - fix subject line to use vmxnet3: instead of Driver:Vmxnet3
 - resubmit when net-next is open

Changes in v4:
 - Address code review comments by Ben Hutchings: remove unnecessary memset
   from vmxnet3_get_coalesce.

Changes in v5:
 - Updated all the patches to add detailed commit messages.

---


Shrikrishna Khare (7):
  vmxnet3: prepare for version 3 changes
  vmxnet3: introduce generalized command interface to configure the
    device
  vmxnet3: allow variable length transmit data ring buffer
  vmxnet3: add receive data ring support
  vmxnet3: add support for get_coalesce, set_coalesce ethtool operations
  vmxnet3: introduce command to register memory region
  vmxnet3: update to version 3

 drivers/net/vmxnet3/Makefile          |   4 +-
 drivers/net/vmxnet3/upt1_defs.h       |   4 +-
 drivers/net/vmxnet3/vmxnet3_defs.h    | 105 ++++++++++++-
 drivers/net/vmxnet3/vmxnet3_drv.c     | 285 ++++++++++++++++++++++++++++------
 drivers/net/vmxnet3/vmxnet3_ethtool.c | 215 +++++++++++++++++++++++--
 drivers/net/vmxnet3/vmxnet3_int.h     |  54 ++++++-
 6 files changed, 585 insertions(+), 82 deletions(-)

-- 
2.8.2
