From: Dominik Brodowski <linux@dominikbrodowski.net>
Subject: [RFC] even more PCMCIA cleanup patches for 2.6.33
Date: Wed, 11 Nov 2009 21:33:03 +0100
Message-ID: <20091111203303.GA7939@comet.dominikbrodowski.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-wireless@vger.kernel.org,
	linux-serial@vger.kernel.org, linux-ide@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: linux-pcmcia@lists.infradead.org
Return-path: <linux-ide-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-ide-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hej,

in addition to the patch series already submitted as RFCs and reviewed[*]
here are 13 more patches intended for submission after 2.6.32 is released.
The patches will be sent to the PCMCIA list shortly, with CC to other
lists if deemed appropriate. Also, they can be found in the "pcmcia-test"
branch at 

	git://git.kernel.org/pub/scm/linux/kernel/git/brodo/pcmcia-2.6.git pcmcia-test

and gitweb at

	http://git.kernel.org/?p=linux/kernel/git/brodo/pcmcia-2.6.git;a=shortlog;h=refs/heads/pcmcia-test


[*] 	- patchset sent on Oct 19
	- patchset sent on Oct 24
	- Russell King's patchset sent on Oct 27

---

Avi Cohen Stuart (1):
      pcmcia: correct handling for Zoomed Video registers in topic.h

Dominik Brodowski (7):
      pcmcia/staging: update comedi drivers
      pcmcia: autoload module pcmcia
      pcmcia: move some window-related code to pcmcia_ioctl.c
      pcmcia: remove unused "window_t" typedef
      pcmcia: pcmcia_request_window() doesn't need a pointer to a pointer
      pcmcia: remove deprecated handle_to_dev() macro
      pcmcia: rework the irq_req_t typedef

Magnus Damm (4):
      pcmcia: Pass struct pcmcia_device to pcmcia_release_window()
      pcmcia: Pass struct pcmcia_device to pcmcia_map_mem_page()
      pcmcia: Pass struct pcmcia_socket to pcmcia_get_mem_page()
      pcmcia: Change window_handle_t logic to unsigned long

Randy Dunlap (1):
      pcmcia: fix printk formats

---

 drivers/ata/pata_pcmcia.c                        |    1 
 drivers/bluetooth/bluecard_cs.c                  |    4 
 drivers/bluetooth/bt3c_cs.c                      |    4 
 drivers/bluetooth/btuart_cs.c                    |    4 
 drivers/bluetooth/dtl1_cs.c                      |    4 
 drivers/char/pcmcia/cm4000_cs.c                  |    2 
 drivers/char/pcmcia/cm4040_cs.c                  |   10 
 drivers/char/pcmcia/ipwireless/hardware.c        |    8 
 drivers/char/pcmcia/ipwireless/main.c            |   28 +-
 drivers/char/pcmcia/synclink_cs.c                |    3 
 drivers/ide/ide-cs.c                             |    1 
 drivers/isdn/hardware/avm/avm_cs.c               |    2 
 drivers/isdn/hisax/avma1_cs.c                    |    2 
 drivers/isdn/hisax/elsa_cs.c                     |    1 
 drivers/isdn/hisax/sedlbauer_cs.c                |    5 
 drivers/isdn/hisax/teles_cs.c                    |    1 
 drivers/mtd/maps/pcmciamtd.c                     |    6 
 drivers/net/pcmcia/3c574_cs.c                    |    6 
 drivers/net/pcmcia/3c589_cs.c                    |    6 
 drivers/net/pcmcia/axnet_cs.c                    |    3 
 drivers/net/pcmcia/com20020_cs.c                 |   10 
 drivers/net/pcmcia/fmvj18x_cs.c                  |   20 -
 drivers/net/pcmcia/ibmtr_cs.c                    |   25 +-
 drivers/net/pcmcia/nmclan_cs.c                   |    6 
 drivers/net/pcmcia/pcnet_cs.c                    |   17 -
 drivers/net/pcmcia/smc91c92_cs.c                 |   14 -
 drivers/net/pcmcia/xirc2ps_cs.c                  |    9 
 drivers/net/wireless/airo_cs.c                   |    7 
 drivers/net/wireless/atmel_cs.c                  |    5 
 drivers/net/wireless/b43/pcmcia.c                |    6 
 drivers/net/wireless/hostap/hostap_cs.c          |    7 
 drivers/net/wireless/libertas/if_cs.c            |    5 
 drivers/net/wireless/netwave_cs.c                |   11 -
 drivers/net/wireless/orinoco/orinoco_cs.c        |    6 
 drivers/net/wireless/orinoco/spectrum_cs.c       |    6 
 drivers/net/wireless/ray_cs.c                    |   22 --
 drivers/net/wireless/wavelan_cs.c                |   11 -
 drivers/net/wireless/wl3501_cs.c                 |    7 
 drivers/parport/parport_cs.c                     |    1 
 drivers/pcmcia/cs.c                              |    7 
 drivers/pcmcia/cs_internal.h                     |    4 
 drivers/pcmcia/pcmcia_ioctl.c                    |   61 +++++
 drivers/pcmcia/pcmcia_resource.c                 |  153 +++++---------
 drivers/pcmcia/topic.h                           |   15 -
 drivers/scsi/pcmcia/aha152x_stub.c               |    1 
 drivers/scsi/pcmcia/fdomain_stub.c               |    1 
 drivers/scsi/pcmcia/nsp_cs.c                     |    8 
 drivers/scsi/pcmcia/qlogic_stub.c                |    1 
 drivers/scsi/pcmcia/sym53c500_cs.c               |    1 
 drivers/serial/serial_cs.c                       |    3 
 drivers/staging/comedi/drivers/cb_das16_cs.c     |  221 +++++----------------
 drivers/staging/comedi/drivers/das08_cs.c        |  203 +++++--------------
 drivers/staging/comedi/drivers/ni_daq_700.c      |  237 +++++++----------------
 drivers/staging/comedi/drivers/ni_daq_dio24.c    |  236 +++++++---------------
 drivers/staging/comedi/drivers/ni_labpc_cs.c     |  225 +++++++--------------
 drivers/staging/comedi/drivers/ni_mio_cs.c       |  127 ++----------
 drivers/staging/comedi/drivers/quatech_daqp_cs.c |  219 +++++----------------
 drivers/usb/host/sl811_cs.c                      |    3 
 include/pcmcia/cs.h                              |   14 -
 include/pcmcia/cs_types.h                        |    3 
 include/pcmcia/ds.h                              |   12 -
 include/pcmcia/ss.h                              |   11 -
 sound/pcmcia/pdaudiocf/pdaudiocf.c               |    6 
 sound/pcmcia/vx/vxpocket.c                       |    6 
 64 files changed, 688 insertions(+), 1386 deletions(-)


Best,
	Dominik

