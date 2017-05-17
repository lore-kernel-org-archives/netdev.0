From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 0/6] net: bridge: factorize MDB new and del functions
Date: Wed, 17 May 2017 17:27:03 -0400
Message-ID: <20170517212709.6473-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The br_mdb.c file implements both br_mdb_add and br_mdb_del functions, to
handle respectively the RTM_NEWMDB and RTM_DELMDB message types.

But these two functions are really similar. This patch series factorizes
them into a single br_mdb_do rtnl_doit_func function to reduce
boilerplate and simplify the MDB handling code.

Vivien Didelot (6):
  net: bridge: pass net_bridge_port to __br_mdb_add
  net: bridge: check multicast bridge only once
  net: bridge: break if __br_mdb_del fails
  net: bridge: add __br_mdb_do
  net: bridge: get msgtype from nlmsghdr in mdb ops
  net: bridge: add br_mdb_do

 net/bridge/br_mdb.c | 107 +++++++++++++++-------------------------------------
 1 file changed, 31 insertions(+), 76 deletions(-)

-- 
2.13.0
