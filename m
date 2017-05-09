From: Fredrik Markstrom <fredrik.markstrom@gmail.com>
Subject: [PATCH 0/2] net: Set maximum receive packet size on veth interfaces
Date: Tue,  9 May 2017 14:44:36 +0200
Message-ID: <20170509124439.45674-1-fredrik.markstrom@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: "David S. Miller" <davem@davemloft.net>,
        Stephen Hemminger <stephen@networkplumber.org>,
        Alexei Starovoitov <ast@kernel.org>,
        Daniel Borkmann <daniel@iogearbox.net>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, bridge@lists.linux-foundation.org,
        Fredrik Markstrom <fredrik.markstrom@gmail.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Currently veth drops all packets larger then the mtu set on the receiving
end of the pair. This is inconsistent with most hardware ethernet drivers.

This patch set adds a new driver attribute to set the maximum size of
received packet to make it possible to create configurations similar to
those possible with (most) hardware ethernet interfaces.

The set consists of two patches. The first one adding a parameter do the
dev_forward_skb functions to specify the maximum packet size, the
second one implents a new attribute (VETH_MRU) in the veth driver.

Fredrik Markstrom (1):
  veth: Added attribute to set maximum receive size on veth interfaces

Fredrik Markström (1):
  net: Added mtu parameter to dev_forward_skb calls

 drivers/net/ipvlan/ipvlan_core.c |  7 ++++---
 drivers/net/macvlan.c            |  4 ++--
 drivers/net/veth.c               | 45 +++++++++++++++++++++++++++++++++++++++-
 include/linux/netdevice.h        | 10 ++++-----
 include/uapi/linux/veth.h        |  1 +
 net/bridge/br_forward.c          |  4 ++--
 net/core/dev.c                   | 17 +++++++++------
 net/core/filter.c                |  4 ++--
 net/l2tp/l2tp_eth.c              |  2 +-
 9 files changed, 72 insertions(+), 22 deletions(-)

-- 
2.11.0
