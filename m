From: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Subject: [PATCH v3] if xen_platform_pci=0 is set don't blow up.
Date: Mon, 16 Dec 2013 10:04:08 -0500
Message-ID: <1387206250-13963-1-git-send-email-konrad.wilk@oracle.com>
To: axboe@kernel.dk, stefano.stabellini@eu.citrix.com,
	ian.campbell@citrix.com, xen-devel@lists.xenproject.org,
	linux-kernel@vger.kernel.org, boris.ostrovsky@oracle.com,
	david.vrabel@citrix.com, leosilva@linux.vnet.ibm.com,
	ashley@ashleylai.com, peterhuewe@gmx.de, mail@srajiv.net,
	tpmdd@selhorst.net, dmitry.torokhov@gmail.com, bhelgaas@google.com,
	plagnioj@jcrosoft.com, tomi.valkeinen@ti.com,
	tpmdd-devel@lists.sourceforge.net, linux-input@vger.kernel.org,
	netdev@vger.kernel.org, linux-pci@vger.kernel.org,
	linux-fbdev@vger.kernel.org
Return-path: <linux-input-owner@vger.kernel.org>
Sender: linux-input-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The first patch:
 [PATCH v3 1/2] xen/pvhvm: If xen_platform_pci=0 is set don't blow up

I would like to commit to stable as it is fixing an eggregious bug -
where we blow up if the guest config has: "xen_platform_pci=0" setup.
This bug has been in existence for years and it is time to stamp it out.

The second patch is a cleanup - not a stable candidate.

It touches all of the Xen frontend drivers and adds the logic of:
"if user disabled us, don't init" - with variations. As you can
specify exactly which ones you want to init and which ones
not (Linux runtime parameter 'xen_emul_unplug'). But for the majority
of drivers - it is just an on/off switch.

Since it touches a lot of maintainers I figured I would send it
to Linus on Wednesday or Thursday.

Thank you!

 arch/x86/xen/platform-pci-unplug.c         | 79 ++++++++++++++++++++++++++++--
 drivers/block/xen-blkfront.c               |  4 +-
 drivers/char/tpm/xen-tpmfront.c            |  4 ++
 drivers/input/misc/xen-kbdfront.c          |  4 ++
 drivers/net/xen-netfront.c                 |  2 +-
 drivers/pci/xen-pcifront.c                 |  4 ++
 drivers/video/xen-fbfront.c                |  4 ++
 drivers/xen/xenbus/xenbus_probe_frontend.c |  2 +-
 include/xen/platform_pci.h                 | 25 +++++++++-
 9 files changed, 119 insertions(+), 9 deletions(-)


Konrad Rzeszutek Wilk (2):
      xen/pvhvm: If xen_platform_pci=0 is set don't blow up (v3).
      xen/pvhvm: Remove the xen_platform_pci int.

