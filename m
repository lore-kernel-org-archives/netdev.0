From: Juergen Gross <jgross@suse.com>
Subject: [PATCH 00/12] xen: add common function for reading optional value
Date: Mon, 31 Oct 2016 17:48:18 +0100
Message-ID: <1477932510-28594-1-git-send-email-jgross@suse.com>
Cc: david.vrabel@citrix.com, boris.ostrovsky@oracle.com,
        Juergen Gross <jgross@suse.com>, konrad.wilk@oracle.com,
        roger.pau@citrix.com, peterhuewe@gmx.de, tpmdd@selhorst.net,
        jarkko.sakkinen@linux.intel.com, jgunthorpe@obsidianresearch.com,
        tpmdd-devel@lists.sourceforge.net, dmitry.torokhov@gmail.com,
        linux-input@vger.kernel.org, wei.liu2@citrix.com,
        paul.durrant@citrix.com, netdev@vger.kernel.org,
        bhelgaas@google.com, linux-pci@vger.kernel.org,
        tomi.valkeinen@ti.com, linux-fbdev@vger.kernel.org
To: linux-kernel@vger.kernel.org, xen-devel@lists.xen.org
Return-path: <linux-pci-owner@vger.kernel.org>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

There are multiple instances of code reading an optional unsigned
parameter from Xenstore via xenbus_scanf(). Instead of repeating the
same code over and over add a service function doing the job and
replace the call of xenbus_scanf() with the call of the new function
where appropriate.

Juergen Gross (12):
  xen: introduce xenbus_read_unsigned()
  xen: make use of xenbus_read_unsigned() in xen-blkback
  xen: make use of xenbus_read_unsigned() in xen-blkfront
  xen: make use of xenbus_read_unsigned() in xen-tpmfront
  xen: make use of xenbus_read_unsigned() in xen-kbdfront
  xen: make use of xenbus_read_unsigned() in xen-netback
  xen: make use of xenbus_read_unsigned() in xen-netfront
  xen: make use of xenbus_read_unsigned() in xen-pcifront
  xen: make use of xenbus_read_unsigned() in xen-scsifront
  xen: make use of xenbus_read_unsigned() in xen-fbfront
  xen: make use of xenbus_read_unsigned() in xen-pciback
  xen: make use of xenbus_read_unsigned() in xenbus

 drivers/block/xen-blkback/xenbus.c        | 36 ++++++--------
 drivers/block/xen-blkfront.c              | 81 ++++++++++---------------------
 drivers/char/tpm/xen-tpmfront.c           |  8 +--
 drivers/input/misc/xen-kbdfront.c         | 13 ++---
 drivers/net/xen-netback/xenbus.c          | 50 ++++++-------------
 drivers/net/xen-netfront.c                | 67 +++++++------------------
 drivers/pci/xen-pcifront.c                |  6 +--
 drivers/scsi/xen-scsifront.c              |  6 +--
 drivers/video/fbdev/xen-fbfront.c         | 13 ++---
 drivers/xen/xen-pciback/xenbus.c          |  8 ++-
 drivers/xen/xenbus/xenbus_probe_backend.c |  8 +--
 drivers/xen/xenbus/xenbus_xs.c            | 22 +++++++--
 include/xen/xenbus.h                      |  4 ++
 13 files changed, 112 insertions(+), 210 deletions(-)

Cc: konrad.wilk@oracle.com
Cc: roger.pau@citrix.com
Cc: peterhuewe@gmx.de
Cc: tpmdd@selhorst.net
Cc: jarkko.sakkinen@linux.intel.com
Cc: jgunthorpe@obsidianresearch.com
Cc: tpmdd-devel@lists.sourceforge.net
Cc: dmitry.torokhov@gmail.com
Cc: linux-input@vger.kernel.org
Cc: wei.liu2@citrix.com
Cc: paul.durrant@citrix.com
Cc: netdev@vger.kernel.org
Cc: bhelgaas@google.com
Cc: linux-pci@vger.kernel.org
Cc: tomi.valkeinen@ti.com
Cc: linux-fbdev@vger.kernel.org
-- 
2.6.6
