From: Antoine Tenart <antoine.tenart@free-electrons.com>
Subject: [PATCH] net: pxa168_eth: avoid using signed char for bitops
Date: Fri,  3 Oct 2014 17:01:54 +0200
Message-ID: <1412348517-20352-2-git-send-email-antoine.tenart@free-electrons.com>
References: <1412348517-20352-1-git-send-email-antoine.tenart@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: thomas.petazzoni@free-electrons.com, zmxu@marvell.com,
 netdev@vger.kernel.org, Antoine Tenart <antoine.tenart@free-electrons.com>,
 linux-kernel@vger.kernel.org, alexandre.belloni@free-electrons.com,
 jszhang@marvell.com, linux-arm-kernel@lists.infradead.org,
 sebastian.hesselbarth@gmail.com
To: dan.carpenter@oracle.com
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <1412348517-20352-1-git-send-email-antoine.tenart@free-electrons.com>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

Signedness bugs may occur when using signed char for bitops,
depending on if the highest bit is ever used.

Signed-off-by: Antoine Tenart <antoine.tenart@free-electrons.com>
Reported-by: Dan Carpenter <dan.carpenter@oracle.com>
---

Dan reported a static checker warning:
http://marc.info/?l=kernel-janitors&m=141218246222535&w=2

This patch fixes it. Instead of using sa->sa_data we now use
dev->dev_addr (of type unsigned char *) to avoid possible
signedness issues.

 drivers/net/ethernet/marvell/pxa168_eth.c | 12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/marvell/pxa168_eth.c b/drivers/net/ethernet/marvell/pxa168_eth.c
index 24de41231593..c3b209cd0660 100644
--- a/drivers/net/ethernet/marvell/pxa168_eth.c
+++ b/drivers/net/ethernet/marvell/pxa168_eth.c
@@ -634,12 +634,12 @@ static int pxa168_eth_set_mac_address(struct net_device *dev, void *addr)
 	memcpy(oldMac, dev->dev_addr, ETH_ALEN);
 	memcpy(dev->dev_addr, sa->sa_data, ETH_ALEN);
 
-	mac_h = sa->sa_data[0] << 24;
-	mac_h |= sa->sa_data[1] << 16;
-	mac_h |= sa->sa_data[2] << 8;
-	mac_h |= sa->sa_data[3];
-	mac_l = sa->sa_data[4] << 8;
-	mac_l |= sa->sa_data[5];
+	mac_h = dev->dev_addr[0] << 24;
+	mac_h |= dev->dev_addr[1] << 16;
+	mac_h |= dev->dev_addr[2] << 8;
+	mac_h |= dev->dev_addr[3];
+	mac_l = dev->dev_addr[4] << 8;
+	mac_l |= dev->dev_addr[5];
 	wrl(pep, MAC_ADDR_HIGH, mac_h);
 	wrl(pep, MAC_ADDR_LOW, mac_l);
 
-- 
1.9.1
