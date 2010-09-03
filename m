From: "Gustavo F. Padovan" <padovan@profusion.mobi>
Subject: Re: [PATCH 06/15] pcmcia: simplify IntType
Date: Fri, 3 Sep 2010 19:36:24 -0300
Message-ID: <20100903223624.GF16973@vigoh>
References: <20100903105628.GA21255@comet.dominikbrodowski.net>
 <1283511434-21620-6-git-send-email-linux@dominikbrodowski.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-pcmcia@lists.infradead.org, netdev@vger.kernel.org,
	linux-wireless@vger.kernel.org, linux-ide@vger.kernel.org,
	linux-usb@vger.kernel.org, laforge@gnumonks.org,
	linux-mtd@lists.infradead.org, linux-bluetooth@vger.kernel.org,
	alsa-devel@alsa-project.org, linux-serial@vger.kernel.org,
	Jiri Kosina <jkosina@suse.cz>, linux-scsi@vger.kernel.org
To: Dominik Brodowski <linux@dominikbrodowski.net>
Return-path: <linux-serial-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1283511434-21620-6-git-send-email-linux@dominikbrodowski.net>
Sender: linux-serial-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* Dominik Brodowski <linux@dominikbrodowski.net> [2010-09-03 12:57:05 +0200]:

> IntType was only set to INT_MEMORY (driver pcmciamtd) or INT_MEMORY_AND_IO
> (all other drivers). As this flags seems to relate to ioport access, make
> it conditional to the driver having requested IO port access. There are two
> drivers which do not request IO ports, but did set INT_MEMORY_AND_IO:
> ray_cs and b43. For those, we consistently only set INT_MEMORY in future.
> 
> CC: netdev@vger.kernel.org
> CC: linux-wireless@vger.kernel.org
> CC: linux-ide@vger.kernel.org
> CC: linux-usb@vger.kernel.org
> CC: laforge@gnumonks.org
> CC: linux-mtd@lists.infradead.org
> CC: linux-bluetooth@vger.kernel.org
> CC: alsa-devel@alsa-project.org
> CC: linux-serial@vger.kernel.org
> CC: Jiri Kosina <jkosina@suse.cz>
> CC: linux-scsi@vger.kernel.org
> Signed-off-by: Dominik Brodowski <linux@dominikbrodowski.net>
> ---
>  drivers/ata/pata_pcmcia.c                        |    1 -
>  drivers/bluetooth/bluecard_cs.c                  |    1 -
>  drivers/bluetooth/bt3c_cs.c                      |    1 -
>  drivers/bluetooth/btuart_cs.c                    |    1 -
>  drivers/bluetooth/dtl1_cs.c                      |    1 -
>  drivers/char/pcmcia/cm4000_cs.c                  |    3 ---
>  drivers/char/pcmcia/cm4040_cs.c                  |    3 ---
>  drivers/char/pcmcia/ipwireless/main.c            |    1 -
>  drivers/char/pcmcia/synclink_cs.c                |    2 --
>  drivers/ide/ide-cs.c                             |    1 -
>  drivers/isdn/hardware/avm/avm_cs.c               |    1 -
>  drivers/isdn/hisax/avma1_cs.c                    |    1 -
>  drivers/isdn/hisax/elsa_cs.c                     |    1 -
>  drivers/isdn/hisax/sedlbauer_cs.c                |    1 -
>  drivers/isdn/hisax/teles_cs.c                    |    1 -
>  drivers/mtd/maps/pcmciamtd.c                     |    2 --
>  drivers/net/pcmcia/3c574_cs.c                    |    1 -
>  drivers/net/pcmcia/3c589_cs.c                    |    1 -
>  drivers/net/pcmcia/axnet_cs.c                    |    1 -
>  drivers/net/pcmcia/com20020_cs.c                 |    1 -
>  drivers/net/pcmcia/fmvj18x_cs.c                  |    1 -
>  drivers/net/pcmcia/ibmtr_cs.c                    |    1 -
>  drivers/net/pcmcia/nmclan_cs.c                   |    1 -
>  drivers/net/pcmcia/pcnet_cs.c                    |    1 -
>  drivers/net/pcmcia/smc91c92_cs.c                 |    1 -
>  drivers/net/pcmcia/xirc2ps_cs.c                  |    1 -
>  drivers/net/wireless/airo_cs.c                   |    1 -
>  drivers/net/wireless/atmel_cs.c                  |    1 -
>  drivers/net/wireless/b43/pcmcia.c                |    1 -
>  drivers/net/wireless/hostap/hostap_cs.c          |    1 -
>  drivers/net/wireless/libertas/if_cs.c            |    1 -
>  drivers/net/wireless/orinoco/orinoco_cs.c        |    1 -
>  drivers/net/wireless/orinoco/spectrum_cs.c       |    1 -
>  drivers/net/wireless/ray_cs.c                    |    1 -
>  drivers/net/wireless/wl3501_cs.c                 |    1 -
>  drivers/parport/parport_cs.c                     |    1 -
>  drivers/pcmcia/cs_internal.h                     |    1 -
>  drivers/pcmcia/pcmcia_resource.c                 |   10 +---------
>  drivers/scsi/pcmcia/aha152x_stub.c               |    1 -
>  drivers/scsi/pcmcia/fdomain_stub.c               |    1 -
>  drivers/scsi/pcmcia/nsp_cs.c                     |    1 -
>  drivers/scsi/pcmcia/qlogic_stub.c                |    1 -
>  drivers/scsi/pcmcia/sym53c500_cs.c               |    1 -
>  drivers/serial/serial_cs.c                       |    2 --
>  drivers/staging/comedi/drivers/cb_das16_cs.c     |    1 -
>  drivers/staging/comedi/drivers/das08_cs.c        |    1 -
>  drivers/staging/comedi/drivers/ni_daq_700.c      |    1 -
>  drivers/staging/comedi/drivers/ni_daq_dio24.c    |    1 -
>  drivers/staging/comedi/drivers/ni_labpc_cs.c     |    1 -
>  drivers/staging/comedi/drivers/ni_mio_cs.c       |    1 -
>  drivers/staging/comedi/drivers/quatech_daqp_cs.c |    1 -
>  drivers/staging/wlags49_h2/wl_cs.c               |    1 -
>  drivers/telephony/ixj_pcmcia.c                   |    1 -
>  drivers/usb/host/sl811_cs.c                      |    1 -
>  include/pcmcia/cs.h                              |    7 -------
>  sound/pcmcia/pdaudiocf/pdaudiocf.c               |    1 -
>  sound/pcmcia/vx/vxpocket.c                       |    1 -
>  57 files changed, 1 insertions(+), 78 deletions(-)
> 

For drivers/bluetooth

Acked-by: Gustavo F. Padovan <padovan@profusion.mobi>

-- 
Gustavo F. Padovan
ProFUSION embedded systems - http://profusion.mobi
