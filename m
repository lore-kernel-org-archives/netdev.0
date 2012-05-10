From: Paul Gortmaker <paul.gortmaker-CWA4WttNNZF54TAoqtyWWQ@public.gmane.org>
Subject: [PATCH 0/3] staging: delete duplicated files/functionality in rtl8712
Date: Wed,  9 May 2012 23:47:18 -0400
Message-ID: <1336621641-15467-1-git-send-email-paul.gortmaker@windriver.com>
Cc: florian.c.schilhabel-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org, ali-H4aWS73dXuqdkR0RstYxLQ@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Paul Gortmaker <paul.gortmaker-CWA4WttNNZF54TAoqtyWWQ@public.gmane.org>,
	Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>,
	Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>
To: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

A git grep happened to lead me into this dir, and once there I couldn't
simply leave and pretend I didn't see the stuff that I saw.

There were duplicated basic networking headers like if_ether.h and
ip.h (of course, some ancient versions, too).  And a whole whack of
boilerplate endian handling functionality duplicated too.

I forced myself to stop looking after that.

Anyway, a trivial redirection onto mainline's networking headers
in the proper include dir, and a deletion of any references to
the endian headers and the thing still happily builds on x86_64
and ppc even after shitcanning seven useless files.

These three commits are against May 8th's linux-next tree.  I've
used "-D" to hide the line-by-line content of the deletions.

Paul.
---
Cc: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Cc: Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>

Paul Gortmaker (3):
  staging: wean rtl8712 off of its ancient duplicate of if_ether.h
  staging: wean rtl8712 off of its ancient duplicate of ip.h
  staging: delete all duplicated endian crap from rtl8712 driver

 drivers/staging/rtl8712/big_endian.h        |   94 --------------
 drivers/staging/rtl8712/generic.h           |  178 ---------------------------
 drivers/staging/rtl8712/hal_init.c          |    1 -
 drivers/staging/rtl8712/if_ether.h          |  141 ---------------------
 drivers/staging/rtl8712/ip.h                |  137 --------------------
 drivers/staging/rtl8712/little_endian.h     |   94 --------------
 drivers/staging/rtl8712/osdep_service.h     |    2 -
 drivers/staging/rtl8712/rtl8712_cmd.c       |    1 -
 drivers/staging/rtl8712/rtl8712_recv.c      |    5 +-
 drivers/staging/rtl8712/rtl8712_xmit.c      |    1 -
 drivers/staging/rtl8712/rtl871x_byteorder.h |   32 -----
 drivers/staging/rtl8712/rtl871x_cmd.c       |    1 -
 drivers/staging/rtl8712/rtl871x_recv.c      |    4 +-
 drivers/staging/rtl8712/rtl871x_xmit.c      |    1 -
 drivers/staging/rtl8712/swab.h              |  131 --------------------
 drivers/staging/rtl8712/usb_ops.c           |    1 -
 drivers/staging/rtl8712/wifi.h              |    1 -
 drivers/staging/rtl8712/xmit_linux.c        |    6 +-
 18 files changed, 7 insertions(+), 824 deletions(-)
 delete mode 100644 drivers/staging/rtl8712/big_endian.h
 delete mode 100644 drivers/staging/rtl8712/generic.h
 delete mode 100644 drivers/staging/rtl8712/if_ether.h
 delete mode 100644 drivers/staging/rtl8712/ip.h
 delete mode 100644 drivers/staging/rtl8712/little_endian.h
 delete mode 100644 drivers/staging/rtl8712/rtl871x_byteorder.h
 delete mode 100644 drivers/staging/rtl8712/swab.h

-- 
1.7.9.1

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
