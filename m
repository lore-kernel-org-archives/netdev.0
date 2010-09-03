From: "Gustavo F. Padovan" <padovan-Y3ZbgMPKUGA34EUeqzHoZw@public.gmane.org>
Subject: Re: [PATCH 10/15] pcmcia: introduce autoconfiguration feature
Date: Fri, 3 Sep 2010 19:38:01 -0300
Message-ID: <20100903223801.GG16973@vigoh>
References: <20100903105628.GA21255@comet.dominikbrodowski.net>
 <1283511434-21620-10-git-send-email-linux@dominikbrodowski.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-pcmcia-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-ide-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, laforge-TgoAw6mPHtdg9hUCZPvPmw@public.gmane.org,
	linux-mtd-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	alsa-devel-K7yf7f+aM1XWsZ/bQMPhNw@public.gmane.org, linux-serial-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Jiri Kosina <jkosina-AlSwsSmVLrQ@public.gmane.org>, linux-scsi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Dominik Brodowski <linux-X3ehHDuj6sIIGcDfoQAp7OTW4wlIGRCZ@public.gmane.org>
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1283511434-21620-10-git-send-email-linux-X3ehHDuj6sIIGcDfoQAp7OTW4wlIGRCZ@public.gmane.org>
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

* Dominik Brodowski <linux-X3ehHDuj6sIIGcDfoQAp7OTW4wlIGRCZ@public.gmane.org> [2010-09-03 12:57:09 +0200]:

> Introduce an autoconfiguration feature to set certain values in
> pcmcia_loop_config(), instead of copying the same code over and over
> in each PCMCIA driver. At first, introduce the following options:
> 
> CONF_AUTO_CHECK_VCC	check or matching Vcc entry
> CONF_AUTO_SET_VPP	set Vpp
> CONF_AUTO_AUDIO		enable the speaker line
> 
> CC: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> CC: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> CC: linux-ide-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> CC: linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> CC: laforge-TgoAw6mPHtdg9hUCZPvPmw@public.gmane.org
> CC: linux-mtd-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
> CC: linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> CC: alsa-devel-K7yf7f+aM1XWsZ/bQMPhNw@public.gmane.org
> CC: linux-serial-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> CC: Jiri Kosina <jkosina-AlSwsSmVLrQ@public.gmane.org>
> CC: linux-scsi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> Signed-off-by: Dominik Brodowski <linux-X3ehHDuj6sIIGcDfoQAp7OTW4wlIGRCZ@public.gmane.org>
> ---
>  drivers/ata/pata_pcmcia.c                        |   23 +----
>  drivers/bluetooth/bt3c_cs.c                      |    7 +-
>  drivers/bluetooth/btuart_cs.c                    |    7 +-
>  drivers/bluetooth/dtl1_cs.c                      |    1 -
>  drivers/char/pcmcia/cm4000_cs.c                  |    1 -
>  drivers/char/pcmcia/cm4040_cs.c                  |    1 -
>  drivers/char/pcmcia/ipwireless/main.c            |    1 -
>  drivers/char/pcmcia/synclink_cs.c                |    1 -
>  drivers/ide/ide-cs.c                             |   23 +----
>  drivers/isdn/hardware/avm/avm_cs.c               |    1 -
>  drivers/isdn/hisax/avma1_cs.c                    |    1 -
>  drivers/isdn/hisax/elsa_cs.c                     |    1 -
>  drivers/isdn/hisax/sedlbauer_cs.c                |   25 +-----
>  drivers/isdn/hisax/teles_cs.c                    |    1 -
>  drivers/net/pcmcia/axnet_cs.c                    |    1 -
>  drivers/net/pcmcia/fmvj18x_cs.c                  |    1 -
>  drivers/net/pcmcia/pcnet_cs.c                    |    1 -
>  drivers/net/pcmcia/smc91c92_cs.c                 |    2 -
>  drivers/net/pcmcia/xirc2ps_cs.c                  |    5 +-
>  drivers/net/wireless/airo_cs.c                   |   17 +---
>  drivers/net/wireless/atmel_cs.c                  |   17 +---
>  drivers/net/wireless/hostap/hostap_cs.c          |   27 +-----
>  drivers/net/wireless/libertas/if_cs.c            |    1 -
>  drivers/net/wireless/orinoco/orinoco_cs.c        |   31 +------
>  drivers/net/wireless/orinoco/spectrum_cs.c       |   24 +----
>  drivers/parport/parport_cs.c                     |    1 -
>  drivers/pcmcia/pcmcia_cis.c                      |   36 ++++++-
>  drivers/scsi/pcmcia/aha152x_stub.c               |    1 -
>  drivers/scsi/pcmcia/fdomain_stub.c               |    1 -
>  drivers/scsi/pcmcia/nsp_cs.c                     |  110 ++++++++-------------
>  drivers/scsi/pcmcia/qlogic_stub.c                |    1 -
>  drivers/scsi/pcmcia/sym53c500_cs.c               |    1 -
>  drivers/serial/serial_cs.c                       |   10 +--
>  drivers/staging/comedi/drivers/cb_das16_cs.c     |    1 -
>  drivers/staging/comedi/drivers/das08_cs.c        |    1 -
>  drivers/staging/comedi/drivers/ni_daq_700.c      |   10 +--
>  drivers/staging/comedi/drivers/ni_daq_dio24.c    |   10 +--
>  drivers/staging/comedi/drivers/ni_labpc_cs.c     |   11 +--
>  drivers/staging/comedi/drivers/ni_mio_cs.c       |    1 -
>  drivers/staging/comedi/drivers/quatech_daqp_cs.c |    1 -
>  drivers/telephony/ixj_pcmcia.c                   |    1 -
>  drivers/usb/host/sl811_cs.c                      |   24 +----
>  include/pcmcia/ds.h                              |    7 +-
>  43 files changed, 120 insertions(+), 329 deletions(-)

For drivers/bluetooth

Acked-by: Gustavo F. Padovan <padovan-Y3ZbgMPKUGA34EUeqzHoZw@public.gmane.org>

-- 
Gustavo F. Padovan
ProFUSION embedded systems - http://profusion.mobi
