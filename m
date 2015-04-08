From: Sudip Mukherjee <sudipm.mukherjee-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 00/14] parport: check success of attach call
Date: Wed,  8 Apr 2015 16:50:26 +0530
Message-ID: <1428492040-5581-1-git-send-email-sudipm.mukherjee@gmail.com>
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-i2c-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-scsi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-spi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, devel-gWbeCf7V1WCQmaza687I9mD2FQJk+8+b@public.gmane.org,
	alsa-devel-K7yf7f+aM1XWsZ/bQMPhNw@public.gmane.org,
	Sudip Mukherjee <sudipm.mukherjee-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>,
	Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>,
	Jean Delvare <jdelvare-l3A5Bk7waGM@public.gmane.org>,
	Wolfram Sang <wsa-z923LK4zBo2bacvFa/9K2g@public.gmane.org>,
	Rodolfo Giometti <giometti-AVVDYK/kqiJWk0Htik3J/w@public.gmane.org>,
	"James E.J. Bottomley" <JBottomley-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>,
	Mark Brown <broonie-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Willy Tarreau <willy-859RlTSWH48dnm+yROfE0A@public.gmane.org>,
	Jaroslav Kysela <perex-/Fr2/VpizcU@public.gmane.org>, Takashi Iwai <tiwai-l3A5Bk7waGM@public.gmane.org>
Return-path: <linux-spi-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-spi-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Currently we are not checking if attach has succeeded or not. Also
parport_register_driver() always return 0 even if attach fails.
But in many places where attach has been used, it can fail.
So, modified the parport code to check the return value of attach and
accordingly return either 0 or error code from parport_register_driver.


Sudip Mukherjee (14):
  parport: return value of attach and parport_register_driver
  ALSA: portman2x4: return proper error values from attach
  ALSA: mts64: return proper error values from attach
  staging: panel: return proper error values from attach
  spi: lm70llp: return proper error values from attach
  spi: butterfly: return proper error values from attach
  [SCSI] ppa: return proper error values from attach
  [SCSI] imm: return proper error values from attach
  pps: return proper error values from attach
  pps: return proper error values from attach
  net: plip: return proper error values from attach
  i2c-parport: return proper error values from attach
  ppdev: return proper error values from attach
  char: lp: return proper error values from attach

 drivers/char/lp.c                        | 16 +++++++++++-----
 drivers/char/ppdev.c                     | 10 +++++++---
 drivers/i2c/busses/i2c-parport.c         |  7 ++++---
 drivers/net/plip/plip.c                  | 16 ++++++++++------
 drivers/parport/share.c                  | 20 +++++++++++++++-----
 drivers/pps/clients/pps_parport.c        |  7 ++++---
 drivers/pps/generators/pps_gen_parport.c |  9 +++++----
 drivers/scsi/imm.c                       |  4 ++--
 drivers/scsi/ppa.c                       |  4 ++--
 drivers/spi/spi-butterfly.c              |  7 ++++---
 drivers/spi/spi-lm70llp.c                |  7 ++++---
 drivers/staging/panel/panel.c            | 11 ++++++-----
 include/linux/parport.h                  |  2 +-
 sound/drivers/mts64.c                    | 13 ++++++++-----
 sound/drivers/portman2x4.c               | 15 ++++++++++-----
 15 files changed, 93 insertions(+), 55 deletions(-)

-- 
1.8.1.2

--
To unsubscribe from this list: send the line "unsubscribe linux-spi" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
