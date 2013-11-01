From: =?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>
Subject: [PATCH net-next 00/24] cdc_ncm: many small and mostly trivial fixes
Date: Fri,  1 Nov 2013 11:16:37 +0100
Message-ID: <1383301021-16613-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-usb@vger.kernel.org,
	Alexey Orishko <alexey.orishko@gmail.com>,
	=?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:49962 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754872Ab3KAKRW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 Nov 2013 06:17:22 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series ended up longer than expected, and it is still not
complete. There is more to come when time allows...

Most changes are trivial. Notable non-trivial changes are
 - removed filtering of identical speed notifications
 - tx_max calulation is changed to count the pad byte if
   necessary, and respect the device limit as an absolute
   upper limit even if it is too low according to the spec
 - remove the bug preventing SET_MAX_DATAGRAM_SIZE from having
   any effect
 - drop the pad-to-max if ZLPs are enabled
 - the driver specific VERSION is dropped
 - dev->hard_mtu is set to tx_max instead of max_datagram_size
   causing usbnet to calculate the qlen based on the real max
   size of tx skbs

This series has been tested, along with the previously posted
cdc_mbim series, on the NCM and MBIM devices I have:
 - Ericsson F5521gw (NCM)
 - Huawei E367 (MBIM)
 - D-Link DWM-156 A7 (MBIM w/ too low dwNtb{In,Out}MaxSize bug)
 - Sierra Wireless MC7710 (MBIM w/ ZLP and CDC Union bugs)

Apart from the D-Link modem dropping a lot less oversized
frames with the fix dedicated to it, there are no end user
noticable functional changes as a result of this series.  But
all the non-trivial changes I listed above are of course
detectable by users looking at that specific area (except maybe
the removed speed notification, which requires a device sending
duplicates to be noticable - I don't have any such device).


Bj=C3=B8rn Mork (24):
  net: cdc_ncm: simplify and optimize frame padding
  net: cdc_ncm: add include protection to cdc_ncm.h
  net: cdc_ncm: remove redundant "intf" field
  net: cdc_ncm: remove redundant endpoint pointers
  net: cdc_ncm: remove redundant netdev field
  net: cdc_ncm: remove unused udev field
  net: cdc_ncm: remove tx_speed and rx_speed fields
  net: cdc_ncm: remove ncm_parm field
  net: cdc_ncm: fix SET_MAX_DATAGRAM_SIZE
  net: cdc_ncm: remove descriptor pointers
  net: cdc_ncm: only the control intf can be probed
  net: cdc_ncm: no point in filling up the NTBs if we send ZLPs
  net: cdc_ncm: remove probe and disconnect wrappers
  net: cdc_ncm: remove ethtool ops
  net: cdc_ncm: set correct dev->hard_mtu
  net: cdc_ncm: log the length we warn about
  net: cdc_ncm: use netif_* and dev_* instead of pr_*
  net: cdc_ncm: log signatures in hex
  net: cdc_ncm: endian convert constants instead of variables
  net: cdc_ncm: drop "extern" from header declarations
  net: cdc_ncm: refactoring cdc_ncm_setup
  net: cdc_ncm: return proper error if setup fails
  net: cdc_ncm: improve bind error debug messages
  net: cdc_ncm: no not set tx_max higher than the device supports

 drivers/net/usb/cdc_mbim.c  |    2 +-
 drivers/net/usb/cdc_ncm.c   |  490 +++++++++++++++++++----------------=
--------
 include/linux/usb/cdc_ncm.h |   30 ++-
 3 files changed, 233 insertions(+), 289 deletions(-)

--=20
1.7.10.4
