From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 0/2] net: dsa: don't unmask port bitmaps
Date: Mon, 23 Oct 2017 14:17:29 -0400
Message-ID: <20171023181731.7977-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

DSA has several bitmaps to store the type of ports: cpu_port_mask,
dsa_port_mask and enabled_port_mask. But the code is inconsistently
unmasking them.

The legacy code tries to unmask cpu_port_mask and dsa_port_mask but
skips enabled_port_mask.

The new bindings unmasks cpu_port_mask and enabled_port_mask but skips
dsa_port_mask.

In fact there is no need to unmask them because we are in the error
path, and they won't be used after. Instead of fixing the unmasking,
simply remove them.

Vivien Didelot (2):
  net: dsa: legacy: don't unmask port bitmaps
  net: dsa: don't unmask port bitmaps

 net/dsa/dsa2.c   | 4 ----
 net/dsa/legacy.c | 4 ----
 2 files changed, 8 deletions(-)

-- 
2.14.2
