From: =?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn-yOkvZcmFvRU@public.gmane.org>
Subject: [PATCH net-next 0/5] qmi_wwan fixes for 3.6
Date: Tue, 19 Jun 2012 12:41:58 +0200
Message-ID: <1340102523-23990-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Oliver Neukum <oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org>, Dan Williams <dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	"Andrew Bird (Sphere Systems)" <ajb-5+cxppFmGx6/3pe1ocb+s/XRex20P6io@public.gmane.org>,
	=?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn-yOkvZcmFvRU@public.gmane.org>
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

None of these are critical, so I don't think they are appropriate
for 3.5 at this point. I've therefore based them on net-next.

The two first patches prepare the driver for the new probing
model introduced by patch #3, which is the main change in this
set.  A RFC version of this was posted to linux-usb 29 May 2012=20
for discussion, as it also implicitly affects the cdc-wdm driver,=20
without any comments so far.

Probing on the data interface was a mistake which was introduced
at a point where I didn't realize that the cdc-wdm subdriver
support was required in any case, because most of the supported
devices only provide a single USB interface. Apart from creating
a confusing and inconsistent driver usage, where some devices would
use cdc-wdm as a subdriver and some would not, a number of real
problems has also shown up.  The most important one at the moment
is the need to make cdc_ether and qmi_wwan cooperate wrt which
devices are supported by which driver.  This is close to impossible
unless the two probes both look at the same control interface. It
is not enough that the probe does this. We need to fine tune the
alias matching, which implies fine tuning the device ID tables.

Completing this change will require removing the now unnecessary
and conflicting device ID entries from cdc-wdm.  This will be
submitted as a separate patch against usb-next to avoid mixing
patches for both trees in one patch set.  There is no build
dependency.

The two last patches are minor obvious editorial fixes.


Bj=C3=B8rn Mork (5):
  net: qmi_wwan: define a structure for driver specific state
  net: qmi_wwan: rearranging to prepare for code sharing
  net: qmi_wwan: bind to both control and data interface
  net: qmi_wwan: shorten driver description
  net: qmi_wwan: use module_usb_driver macro

 drivers/net/usb/qmi_wwan.c |  308 +++++++++++++++++++++++-------------=
--------
 1 file changed, 163 insertions(+), 145 deletions(-)

--=20
1.7.10

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
