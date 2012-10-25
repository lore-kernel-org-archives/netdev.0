From: Claudio Fontana <Claudio.Fontana@huawei.com>
Subject: [PATCH] net/ipv4/ipconfig: add device address to a KERN_INFO message
Date: Thu, 25 Oct 2012 09:13:49 +0200
Message-ID: <5088E6AD.2040302@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
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

Hello,

while troubleshooting an issue I was having trying to mount the root
filesystem using nfsroot running on a software emulation (solved),
I found it useful to be able to see the selected device address in the
"IP-Config: Complete" message during boot as I was troubleshooting,
and I thought it might be good in general, and a good way to try to
submit my first patch :)

The patch is against latest mainline.

Thank you for your help and comments,

Claudio Fontana
