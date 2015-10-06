From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 0/3] net: remove dsa.h from netdevice.h
Date: Tue,  6 Oct 2015 17:54:24 -0400
Message-ID: <1444168467-10293-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Scott Feldman <sfeldma@gmail.com>,
	Jiri Pirko <jiri@resnulli.us>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Andrew Lunn <andrew@lunn.ch>,
	Neil Armstrong <narmstrong@baylibre.com>,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In order to push switchdev objects down to DSA drivers, I need to include
switchdev.h in dsa.h. But compilation fails because of a circular dependency
issue, since dsa.h is also included in linux/netdevice.h.

dsa.h is included for two purposes: to have the definition of struct
dsa_switch_tree; and to have access to dsa_uses_tagged_protocol(), used by
netdev_uses_dsa().

This patchset forward declares struct dsa_switch_tree; adds a new uses_hw_tag
boolean to struct net_device, which is more explicit than the DSA helper, and
finally get rid of the dsa.h include.

With this patchset, switchdev.h can safely be included in dsa.h.

Vivien Didelot (3):
  net: dsa: add uses_hw_tag
  net: dsa: include dsa.h in dsa_priv.h
  net: remove dsa.h include from linux/netdevice.h

 include/linux/netdevice.h | 9 ++++++---
 include/net/dsa.h         | 5 -----
 net/dsa/dsa.c             | 1 +
 net/dsa/dsa_priv.h        | 1 +
 4 files changed, 8 insertions(+), 8 deletions(-)

-- 
2.6.0
