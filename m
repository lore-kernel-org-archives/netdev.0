From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 0/4] net: Incorrect use of phy_read_status()
Date: Mon,  6 Feb 2017 15:55:19 -0800
Message-ID: <20170206235523.23216-1-f.fainelli@gmail.com>
Cc: zefir.kurtisi@neratec.com, Florian Fainelli <f.fainelli@gmail.com>,
        Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
        Wingman Kwok <w-kwok2@ti.com>,
        Murali Karicheri <m-karicheri2@ti.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        "David S. Miller" <davem@davemloft.net>,
        Philippe Reynes <tremyfr@gmail.com>,
        Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
        Jisheng Zhang <jszhang@marvell.com>,
        Jarod Wilson <jarod@redhat.com>,
        linux-kernel@vger.kernel.org (open list)
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

This patch series removes incorrect uses of phy_read_status() which can clobber
the PHY device link while we are executing with the state machine running.

greth was potentially another candidate, but it does funky stuff with
auto-negotation that I am still trying to understand.

Florian Fainelli (4):
  net: mv643xx_eth: Do not clobber PHY link outside of state machine
  net: pxa168_eth: Do not clobber PHY link outside of state machine
  net: netcp: Do not clobber PHY link outside of state machine
  net: dsa: Do not clobber PHY link outside of state machine

 drivers/net/ethernet/marvell/mv643xx_eth.c |  4 +---
 drivers/net/ethernet/marvell/pxa168_eth.c  | 20 +-------------------
 drivers/net/ethernet/ti/netcp_ethss.c      |  2 --
 net/dsa/slave.c                            | 10 +++-------
 4 files changed, 5 insertions(+), 31 deletions(-)

-- 
2.9.3
