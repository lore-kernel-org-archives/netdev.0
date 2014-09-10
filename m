From: Beniamino Galvani <b.galvani@gmail.com>
Subject: [PATCH v2 0/2] net: arc_emac: fix tx issues
Date: Wed, 10 Sep 2014 22:50:01 +0200
Message-ID: <1410382203-10395-1-git-send-email-b.galvani@gmail.com>
Cc: Romain Perier <romain.perier@gmail.com>,
	=?UTF-8?q?Heiko=20St=C3=BCbner?= <heiko@sntech.de>,
	Arnd Bergmann <arnd@arndb.de>,
	Tobias Klauser <tklauser@distanz.ch>,
	Jingoo Han <jg1.han@samsung.com>,
	Max Schwarz <max.schwarz@online.de>,
	Florian Fainelli <f.fainelli@gmail.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Beniamino Galvani <b.galvani@gmail.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

the patches below solve some issues found in the tx ring reclaim
strategy currently implemented in the arc_emac driver.

Without these patches a simple outgoing UDP flow blocks almost
immediately with the socket send buffer full, until some new rx
packets trigger a clean of the tx ring.

Everything seems to work fine on a Radxa Rock with this fix applied.

Changes since v1:
 - reworded commit messages

Beniamino Galvani (2):
  net: arc_emac: enable tx interrupts
  net: arc_emac: prevent reuse of unreclaimed tx descriptors

 drivers/net/ethernet/arc/emac_main.c | 53 +++++++++++++++++++++++++-----------
 1 file changed, 37 insertions(+), 16 deletions(-)

-- 
1.9.1
