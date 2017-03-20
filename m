From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Subject: [PATCH 4.10 34/63] team: use ETH_MAX_MTU as max mtu
Date: Mon, 20 Mar 2017 18:51:59 +0100
Message-ID: <20170320174745.095987919@linuxfoundation.org>
References: <20170320174742.712298584@linuxfoundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        stable@vger.kernel.org, Cong Wang <xiyou.wangcong@gmail.com>,
        Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org,
        Jarod Wilson <jarod@redhat.com>,
        "David S. Miller" <davem@davemloft.net>
To: linux-kernel@vger.kernel.org
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <20170320174742.712298584@linuxfoundation.org>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

4.10-stable review patch.  If anyone has any objections, please let me know.

------------------

From: Jarod Wilson <jarod@redhat.com>


[ Upstream commit 3331aa378e9bcbd0d16de9034b0c20f4050e26b4 ]

This restores the ability to set a team device's mtu to anything higher
than 1500. Similar to the reported issue with bonding, the team driver
calls ether_setup(), which sets an initial max_mtu of 1500, while the
underlying hardware can handle something much larger. Just set it to
ETH_MAX_MTU to support all possible values, and the limitations of the
underlying devices will prevent setting anything too large.

Fixes: 91572088e3fd ("net: use core MTU range checking in core net infra")
CC: Cong Wang <xiyou.wangcong@gmail.com>
CC: Jiri Pirko <jiri@resnulli.us>
CC: netdev@vger.kernel.org
Signed-off-by: Jarod Wilson <jarod@redhat.com>
Signed-off-by: David S. Miller <davem@davemloft.net>
Signed-off-by: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
---
 drivers/net/team/team.c |    1 +
 1 file changed, 1 insertion(+)

--- a/drivers/net/team/team.c
+++ b/drivers/net/team/team.c
@@ -2075,6 +2075,7 @@ static int team_dev_type_check_change(st
 static void team_setup(struct net_device *dev)
 {
 	ether_setup(dev);
+	dev->max_mtu = ETH_MAX_MTU;
 
 	dev->netdev_ops = &team_netdev_ops;
 	dev->ethtool_ops = &team_ethtool_ops;
