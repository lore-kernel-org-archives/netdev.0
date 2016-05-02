From: "=?UTF-8?q?Jo=C3=A3o=20Paulo=20Rechi=20Vita?=" <jprvita@gmail.com>
Subject: [RESEND PATCH 0/3] RFKill airplane-mode indicator
Date: Mon,  2 May 2016 10:39:05 -0400
Message-ID: <1462199948-6424-1-git-send-email-jprvita@endlessm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Darren Hart <dvhart@infradead.org>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	platform-driver-x86@vger.kernel.org, linux-api@vger.kernel.org,
	linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux@endlessm.com,
	=?UTF-8?q?Jo=C3=A3o=20Paulo=20Rechi=20Vita?= <jprvita@endlessm.com>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f195.google.com ([209.85.220.195]:33907 "EHLO
	mail-qk0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754024AbcEBOj1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 May 2016 10:39:27 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series implements an airplane-mode indicator LED trigger, which ca=
n be
used by platform drivers. By default the trigger fires on RFKILL_OP_CHA=
NGE_ALL,
but this policy can be overwritten by userspace using the new operation=
s
_AIRPLANE_MODE_INDICATOR_ACQUIRE and _AIRPLANE_MODE_INDICATOR_CHANGE. W=
hen the
airplane-mode indicator state changes, userspace gets notifications thr=
ough the
RFKill control misc device (/dev/rfkill). I also have patches to the rf=
kill
userspace tool that makes use of this interface, so it can serve as API=
 usage
example and to do quick checks on a running system, which I'll send in =
a
separate series.

After some hiatus I found the time to get back to this, and this time I=
've used
Jouni's hwsim suite to test the patches on top of mac80211-next/master.=
 Lines
containing rfkill are pasted bellow:

START wext_rfkill 14/1880
PASS wext_rfkill 4.100002 2016-04-29 12:30:23.792682
START rfkill_wpas 571/1880
PASS rfkill_wpas 1.245307 2016-04-29 12:48:51.804344
START rfkill_autogo 572/1880
PASS rfkill_autogo 1.154174 2016-04-29 12:48:52.959605
START rfkill_p2p_discovery 573/1880
PASS rfkill_p2p_discovery 0.534903 2016-04-29 12:48:53.495547
START rfkill_open 574/1880
PASS rfkill_open 0.34073 2016-04-29 12:48:53.836963
START rfkill_p2p_discovery_p2p_dev 575/1880
PASS rfkill_p2p_discovery_p2p_dev 1.159446 2016-04-29 12:48:54.997555
START rfkill_hostapd 576/1880
PASS rfkill_hostapd 3.686868 2016-04-29 12:48:58.685162
START rfkill_wpa2_psk 577/1880
PASS rfkill_wpa2_psk 0.330014 2016-04-29 12:48:59.016711

Jo=C3=A3o Paulo Rechi Vita (3):
  rfkill: Create "rfkill-airplane-mode" LED trigger
  rfkill: Userspace control for airplane mode
  rfkill: Notify userspace of airplane-mode state changes

 Documentation/rfkill.txt    |  15 +++++++
 include/uapi/linux/rfkill.h |   6 +++
 net/rfkill/core.c           | 100 ++++++++++++++++++++++++++++++++++++=
+++++++-
 3 files changed, 119 insertions(+), 2 deletions(-)

--=20
2.5.0
