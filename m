From: Claudio Fontana <Claudio.Fontana@huawei.com>
Subject: [PATCH resend 2] net/ipv4/ipconfig: add device address to a KERN_INFO
 message
Date: Thu, 25 Oct 2012 13:15:43 +0200
Message-ID: <50891F5F.7060003@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7BIT
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


adds a "hwaddr" to the "IP-Config: Complete" KERN_INFO message
with the dev_addr of the device selected for auto configuration.

Signed-off-by: Claudio Fontana <claudio.fontana@huawei.com>
---
 net/ipv4/ipconfig.c |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/ipconfig.c b/net/ipv4/ipconfig.c
index 798358b..d763701 100644
--- a/net/ipv4/ipconfig.c
+++ b/net/ipv4/ipconfig.c
@@ -1500,8 +1500,10 @@ static int __init ip_auto_config(void)
 	 * Clue in the operator.
 	 */
 	pr_info("IP-Config: Complete:\n");
-	pr_info("     device=%s, addr=%pI4, mask=%pI4, gw=%pI4\n",
-		ic_dev->name, &ic_myaddr, &ic_netmask, &ic_gateway);
+
+	pr_info("     device=%s, hwaddr=%*phC, ipaddr=%pI4, mask=%pI4, gw=%pI4\n",
+		ic_dev->name, ic_dev->addr_len, ic_dev->dev_addr,
+		&ic_myaddr, &ic_netmask, &ic_gateway);
 	pr_info("     host=%s, domain=%s, nis-domain=%s\n",
 		utsname()->nodename, ic_domain, utsname()->domainname);
 	pr_info("     bootserver=%pI4, rootserver=%pI4, rootpath=%s",
-- 
1.7.4.4

I tried to disable the mail client unwanted features.
I hope it works this time.. sorry for that.

Claudio Fontana
