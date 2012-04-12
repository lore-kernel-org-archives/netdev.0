From: =?UTF-8?q?Sjur=20Br=C3=A6ndeland?= <sjur.brandeland@stericsson.com>
Subject: [PATCH net-next 0/4] New CAIF features
Date: Thu, 12 Apr 2012 20:27:23 +0200
Message-ID: <1334255247-3372-1-git-send-email-sjur.brandeland@stericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: sjurbren@gmail.com,
	=?UTF-8?q?Sjur=20Br=C3=A6ndeland?= <sjur.brandeland@stericsson.com>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f174.google.com ([209.85.217.174]:64652 "EHLO
	mail-lb0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933269Ab2DLS1g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Apr 2012 14:27:36 -0400
Received: by lbbgm6 with SMTP id gm6so1843188lbb.19
        for <netdev@vger.kernel.org>; Thu, 12 Apr 2012 11:27:35 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add feature to aggregate CAIF HSI frames into one large HSI-transfer.
The triggers for starting a HSI transfer are:
Max transfer size reached, timeout or reception of low-latency traffic.=
=20
As long as none of these triggers are met, CAIF-frames will be aggregat=
ed.
=20
In order to be able to support aggregation and detect low-latency traff=
ic,
CAIF packets are assigned a TC class.
=20
In addition we are now allowing other kernel modules to use the HSI int=
erface
while the CAIF interface is closed. The CAIF-HSI interface is changed s=
o that
reference to the HSI interface is held only when CAIF-HSI is in state U=
P.
Initialization/de-initialization of the HSI HW is performed when the in=
terface
is opened/closed instead of at module load time.

NOTE: This patch-set depends on the patch "caif-hsi: Free flip_buffer a=
t shutdown",
sent in the Bug-fix patch-set.

Regards,
Sjur

--
Dmitry Tarnyagin (2):
  caif: set traffic class for caif packets
  caif-hsi: robust frame aggregation for HSI

Sjur Br=C3=A6ndeland (2):
  caif-hsi: Remove stop/start of queue.
  caif-hsi: Postpone init of HSI until open()

 drivers/net/caif/caif_hsi.c |  350 ++++++++++++++++++++++++++++-------=
-------
 include/net/caif/caif_hsi.h |   19 ++-
 include/net/caif/cfpkt.h    |    9 +-
 net/caif/caif_socket.c      |   16 ++-
 net/caif/cfctrl.c           |    4 +
 net/caif/cfpkt_skbuff.c     |    7 +
 net/caif/cfsrvl.c           |    3 +
 7 files changed, 286 insertions(+), 122 deletions(-)

--=20
1.7.5.4
