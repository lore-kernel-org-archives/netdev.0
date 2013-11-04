From: =?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn-yOkvZcmFvRU@public.gmane.org>
Subject: [PATCH net-next v6 0/3] The huawei_cdc_ncm driver
Date: Mon,  4 Nov 2013 09:50:46 +0100
Message-ID: <1383555049-24834-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Enrico Mioso <mrkiko.rs-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Oliver Neukum <oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org>,
	=?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn-yOkvZcmFvRU@public.gmane.org>
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Enrico has been kind enough to let me repost his driver with the change=
s
requested by Oliver Neukum during the last review of this series.

The changes I have made from Enricos original v5 series to this version
are:

v6:
 - fix to avoid corrupting drvstate->pmcount
 - fix error return value from huawei_cdc_ncm_suspend()
 - drop redundant testing for subdriver->suspend during resume
 - broke a few lines to keep within the 80 columns recommendation
 - rebased on top of current net-next

Enrico's orginal introduction to the v5 series follows below.  It expla=
ins
the background much better than I can.

Bj=C3=B8rn


[quote Enrico Mioso]

So this is a new, revised, edition of the huawei_cdc_ncm.c driver, whic=
h=20
supports devices resembling the NCM standard, but using it also as a me=
an=20
to encapsulate other protocols, as is the case for the Huawei E3131 and
E3251 modem devices.
Some precisations are needed however - and I encourage discussion on th=
is: and=20
that's why I'm sending this message with a broader CC.
Merging those patches might change:
- the way Modem Manager interacts with those devices
- some regressions might be possible if there are some unknown firmware=
=20
  variants around (Franko?)

=46irst of all: I observed the behaviours of two devices.
Huawei E3131: this device doesn't accept NDIS setup requests unless the=
y're=20
sent via the embedded AT channel exposed by this driver.
So actually we gain funcionality in this case!

The second case, is the Huawei E3251: which works with standard NCM dri=
ver,=20
still exposing an AT embedded channel. Whith this patch set applied, yo=
u gain=20
some funcionality, loosing the ability to catch standard NCM events for=
 now.
The device will work in both ways with no problems, but this has to be=20
acknowledged and discussed. Might be we can develop this driver further=
 to=20
change this, when more devices are tested.

We where thinking Huawei changed their interfaces on new devices - but =
probably=20
this driver only works around a nice firmware bug present in E3131, whi=
ch=20
prevented the modem from being used in NDIS mode.

I think committing this is definitely wortth-while, since it will allow=
 for=20
more Huawei devices to be used without serial connection. Some devices =
like the=20
E3251 also, reports some status information only via the embedded AT ch=
annel,=20
at least in my case.
Note: I'm not subscribed to any list except the Modem Manager's one, so=
 please=20
CC me, thanks!!

[/quote]

Enrico Mioso (3):
  net: cdc_ncm: Export cdc_ncm_{tx,rx}_fixup functions for re-use
  net: huawei_cdc_ncm: Introduce the huawei_cdc_ncm driver
  net: cdc_ncm: remove non-standard NCM device IDs

 drivers/net/usb/Kconfig          |   15 +++
 drivers/net/usb/Makefile         |    1 +
 drivers/net/usb/cdc_ncm.c        |   17 +--
 drivers/net/usb/huawei_cdc_ncm.c |  230 ++++++++++++++++++++++++++++++=
++++++++
 include/linux/usb/cdc_ncm.h      |    3 +
 5 files changed, 253 insertions(+), 13 deletions(-)
 create mode 100644 drivers/net/usb/huawei_cdc_ncm.c

--=20
1.7.10.4

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
