From: =?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn-yOkvZcmFvRU@public.gmane.org>
Subject: [PATCH v2 net-next 0/8] cdc_ncm: fixes and conversion to sysfs API
Date: Fri, 30 May 2014 09:31:02 +0200
Message-ID: <1401435070-26721-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Alexey Orishko <alexey.orishko-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Oliver Neukum <oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org>,
	Enrico Mioso <mrkiko.rs-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	David Laight <David.Laight-ZS65k/vG3HxXrIkS9f7CXA@public.gmane.org>,
	Lars Melin <larsm17-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Peter Stuge <peter-Y+HMSxxDrH8@public.gmane.org>,
	Greg Suarez <gsuarez-AKjrjAf1O7qe8kRwQpwjMg@public.gmane.org>,
	=?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn-yOkvZcmFvRU@public.gmane.org>
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

After considering the comments received after the ethtool coalesce
support was commited, I have ended up concluding that we should
remove it again, while we can, before it hits a release. The idea
was not well enough thought through, and all comments received
pointed to advantages of using a sysfs based API instead.

This series removes the ethtool coalesce support and replaces it
with sysfs attributes in a driver specific group under the netdev.

The first 3 patches are unrelated fixes:

patch 1: reducing truesize as discussed
patch 2: fixing a potentional buffer overrun when changing tx_max
patch 3: prevent framing errors when changing rx_max


Changes v2:
 - minor editorial changes to patch 8, as suggested by Peter Stuge


Bj=C3=B8rn Mork (8):
  net: cdc_ncm: reduce skb truesize in rx path
  net: cdc_ncm: always reallocate tx_curr_skb when tx_max increases
  net: cdc_ncm: inform usbnet when rx buffers are reduced
  net: cdc_ncm: use sysfs for rx/tx aggregation tuning
  net: cdc_ncm: drop ethtool coalesce support
  net: cdc_ncm: export NCM Transfer Block (NTB) parameters
  net: cdc_ncm: allow tuning min_tx_pkt
  net: cdc_ncm: document the sysfs API

 Documentation/ABI/testing/sysfs-class-net-cdc_ncm | 149 ++++++++++++
 drivers/net/usb/cdc_ncm.c                         | 268 ++++++++++++++=
++------
 2 files changed, 341 insertions(+), 76 deletions(-)
 create mode 100644 Documentation/ABI/testing/sysfs-class-net-cdc_ncm

--=20
2.0.0.rc4

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
