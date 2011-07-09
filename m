From: =?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Subject: [PATCH 00/21] clean up rx_copybreak handling [split version]
Date: Sat,  9 Jul 2011 19:17:51 +0200 (CEST)
Message-ID: <cover.1310229312.git.mirq-linux@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Steffen Klassert <klassert@mathematik.tu-chemnitz.de>,
	Santiago Leon <santil@linux.vnet.ibm.com>,
	Tim Hockin <thockin@hockin.org>,
	Don Fry <pcnet32@frontier.com>,
	Francois Romieu <romieu@fr.zoreil.com>,
	Ion Badulescu <ionut@badula.org>,
	Matt Carlson <mcarlson@broadcom.com>,
	Michael Chan <mchan@broadcom.com>,
	Grant Grundler <grundler@parisc-linux.org>,
	David Dillow <dave@thedillows.org>,
	Roger Luethi <rl@hellgate.ch>,
	"David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:37398 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754060Ab1GIRRx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 9 Jul 2011 13:17:53 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Split version of rx_copybreak cleanup patch.

Drivers marked with "[strict refill!]" are dropping packets from
rx queue's head when under memory pressure.

[Patch 1 is the same as the one I sent yesterday]
[Driver patches Cc limited to relevant maintainers, as found in MAINTAI=
NERS]

Best Regards,
Micha=C5=82 Miros=C5=82aw
---

Micha=C5=82 Miros=C5=82aw (21):
  net: wrap common patterns of rx handler code
  net: 3c59x: use common rx_copybreak handling
  net: epic100: use common rx_copybreak handling
  net: fealnx: use common rx_copybreak handling
  net: hamachi: use common rx_copybreak handling
  net: ibmveth: make rx_copybreak threshold consistent with other
    drivers
  net: lib82596: use common rx_copybreak handling [strict refill!]
  net: natsemi: use common rx_copybreak handling
  net: pcnet32: use common rx_copybreak handling [strict refill!]
  net: sgiseeq: use common rx_copybreak handling [strict refill!]
  net: sis190: use common rx_copybreak handling
  net: starfire: use common rx_copybreak handling
  net: sundance: use common rx_copybreak handling
  net: tg3: mark bad rx handler behaviour [strict refill!]
  net: tulip/de2104x: use common rx_copybreak handling [strict refill!]
  net: tulip/interrupt: use common rx_copybreak handling
  net: tulip/winbond-840: use common rx_copybreak handling
  net: typhoon: use common rx_copybreak handling
  net: via-rhine: use common rx_copybreak handling
  net: via-velocity: use common rx_copybreak handling
  net: yellowfin: use common rx_copybreak handling

 drivers/net/3c59x.c             |   23 ++-----
 drivers/net/epic100.c           |   32 +++-------
 drivers/net/fealnx.c            |   39 ++----------
 drivers/net/hamachi.c           |   43 +++-----------
 drivers/net/ibmveth.c           |    2 +-
 drivers/net/lib82596.c          |   66 ++++----------------
 drivers/net/natsemi.c           |   30 ++--------
 drivers/net/pcnet32.c           |   52 +++-------------
 drivers/net/sgiseeq.c           |   66 ++++++++------------
 drivers/net/sis190.c            |   38 ++----------
 drivers/net/starfire.c          |   27 +++------
 drivers/net/sundance.c          |   26 ++------
 drivers/net/tg3.c               |    2 +
 drivers/net/tulip/de2104x.c     |   38 +++---------
 drivers/net/tulip/interrupt.c   |   77 +++++------------------
 drivers/net/tulip/winbond-840.c |   25 ++------
 drivers/net/typhoon.c           |   26 ++------
 drivers/net/via-rhine.c         |   37 ++----------
 drivers/net/via-velocity.c      |   59 +++---------------
 drivers/net/yellowfin.c         |   27 ++------
 include/linux/skbuff.h          |  129 +++++++++++++++++++++++++++++++=
++++++++
 21 files changed, 291 insertions(+), 573 deletions(-)

--=20
1.7.5.4

