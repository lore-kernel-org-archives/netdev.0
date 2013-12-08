From: =?UTF-8?q?Pali=20Roh=C3=A1r?= <pali.rohar@gmail.com>
Subject: [PATCH v2 00/16] wl1251 patches from linux-n900 tree
Date: Sun,  8 Dec 2013 10:24:58 +0100
Message-ID: <1386494714-21070-1-git-send-email-pali.rohar@gmail.com>
References: <1382819655-30430-1-git-send-email-pali.rohar@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, freemangordon@abv.bg,
	aaro.koskinen@iki.fi, pavel@ucw.cz, sre@ring0.de,
	joni.lapilainen@gmail.com,
	Johannes Berg <johannes@sipsolutions.net>,
	Felipe Contreras <felipe.contreras@gmail.com>,
	=?UTF-8?q?Pali=20Roh=C3=A1r?= <pali.rohar@gmail.com>
To: Luciano Coelho <luca@coelho.fi>,
	"John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f175.google.com ([209.85.215.175]:52471 "EHLO
	mail-ea0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751445Ab3LHJ1P (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 Dec 2013 04:27:15 -0500
In-Reply-To: <1382819655-30430-1-git-send-email-pali.rohar@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello, I'm sending wl1251 patches from linux-n900 tree [1] for comments=
=2E More
patches come from David's monitor & packet injection work. Patches are =
tested
with 3.12 rc5 kernel on Nokia N900.

Second version contains new patch for fixing NULL pointer dereference w=
hich
sometimes cause kernel panic and fixes code suggested by Pavel Machek.

[1] - https://gitorious.org/linux-n900/linux-n900

David Gnedt (12):
  wl1251: fix scan behaviour while not associated
  wl1251: add sysfs interface for bluetooth coexistence mode
    configuration
  wl1251: retry power save entry
  wl1251: implement hardware ARP filtering
  wl1251: split RX and TX data path initialisation
  wl1251: configure hardware en-/decryption for monitor mode
  wl1251: implement multicast address filtering
  wl1251: disable power saving in monitor mode
  wl1251: fix channel switching in monitor mode
  wl1251: enable tx path in monitor mode if necessary for packet
    injection
  wl1251: disable retry and ACK policy for injected packets
  wl1251: enforce changed hw encryption support on monitor state change

Pali Roh=C3=A1r (4):
  wl1251: add nvs file name to module firmware list
  wl1251: Add sysfs file tx_mgmt_frm_rate for setting rate
  wl1251: Add sysfs file address for setting permanent mac address
  wl1251: fix NULL pointer dereference

 drivers/net/wireless/ti/wl1251/acx.c    |   92 +++++-
 drivers/net/wireless/ti/wl1251/acx.h    |   34 ++-
 drivers/net/wireless/ti/wl1251/boot.c   |    3 +-
 drivers/net/wireless/ti/wl1251/cmd.c    |   59 +++-
 drivers/net/wireless/ti/wl1251/cmd.h    |    8 +-
 drivers/net/wireless/ti/wl1251/event.c  |   46 ++-
 drivers/net/wireless/ti/wl1251/event.h  |    7 +
 drivers/net/wireless/ti/wl1251/init.c   |   19 +-
 drivers/net/wireless/ti/wl1251/main.c   |  462 +++++++++++++++++++++++=
+++++++-
 drivers/net/wireless/ti/wl1251/rx.c     |    2 +-
 drivers/net/wireless/ti/wl1251/tx.c     |   35 ++-
 drivers/net/wireless/ti/wl1251/wl1251.h |   14 +
 12 files changed, 720 insertions(+), 61 deletions(-)

--=20
1.7.9.5
