From: Jeff Garzik <jgarzik@pobox.com>
Subject: [bk patches] 2.4.x net driver updates
Date: Mon, 1 Sep 2003 11:49:45 -0400
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <20030901154945.GA22275@gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: marcelo@conectiva.com.br, linux-kernel@vger.kernel.org,
	netdev@oss.sgi.com
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org@vger.kernel.org>
To: marcelo@parcelfarce.linux.theplanet.co.uk
Content-Disposition: inline
List-Id: netdev.vger.kernel.org


Marcelo, please do a

	bk pull bk://kernel.bkbits.net/jgarzik/net-drivers-2.4

This will update the following files:

 drivers/net/8139cp.c  |   35 ++++++++-----------------
 drivers/net/8139too.c |   68 ++++++++++++++++++++++++--------------------------
 2 files changed, 44 insertions(+), 59 deletions(-)

through these ChangeSets:

<jgarzik@redhat.com> (03/08/31 1.1119)
   [netdrvr 8139cp] PCI MWI cleanup; remove unneeded workaround
   
   * The PCI layer now handles incorrect cacheline size settings,
     as it should.  Remove our own workarounds.
   * Move pci_set_mwi up much earlier in the probe process,
     and check its return value.
   * Call pci_clear_mwi() in ->probe error handling
   * Call pci_clear_mwi() in ->remove

<hirofumi@mail.parknet.co.jp> (03/08/31 1.1117)
   [netdrvr 8139too] don't start thread when it's not needed
   
       The thread for was unneeded on chips other than CH_8139_K/8129. So,
       this patch doesn't create the thread on chips other than
       CH_8139_K/8129.
   

<hirofumi@mail.parknet.co.jp> (03/08/31 1.1116)
   [netdrvr 8139too] remove driver-based poisoning of net_device
   
   Harmless in 2.4, but causes oopses on rmmod in 2.6.
   
   slab poisoning can take care of this for us, anyway.

<jgarzik@redhat.com> (03/08/31 1.1115)
   [netdrvr 8139cp] must call NAPI-specific vlan hook
