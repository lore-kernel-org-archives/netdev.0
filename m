From: "K. Y. Srinivasan" <kys@microsoft.com>
Subject: [PATCH V2 net 1/1] hyperv: Properly handle checksum offload
Date: Wed, 30 Apr 2014 11:58:25 -0700
Message-ID: <1398884305-21618-1-git-send-email-kys@microsoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: davem@davemloft.net, netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
 devel@linuxdriverproject.org, olaf@aepfle.de, apw@canonical.com,
 jasowang@redhat.com
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: driverdev-devel-bounces@linuxdriverproject.org
List-Id: netdev.vger.kernel.org

Do checksum offload only if the client of the driver wants checksum to be
offloaded.

In V1 version of this patch, I  addressed comments from
Stephen Hemminger <stephen@networkplumber.org> and
Eric Dumazet <eric.dumazet@gmail.com>.

In this version of the patch I have addressed comments from
David Miller.

This patch fixes a bug that is exposed in gateway scenarios.

Signed-off-by: K. Y. Srinivasan <kys@microsoft.com>
Reviewed-by: Haiyang Zhang <haiyangz@microsoft.com>
---
 drivers/net/hyperv/netvsc_drv.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/drivers/net/hyperv/netvsc_drv.c b/drivers/net/hyperv/netvsc_drv.c
index 939e3af..64c7816 100644
--- a/drivers/net/hyperv/netvsc_drv.c
+++ b/drivers/net/hyperv/netvsc_drv.c
@@ -467,6 +467,10 @@ static int netvsc_start_xmit(struct sk_buff *skb, struct net_device *net)
 	if (skb_is_gso(skb))
 		goto do_lso;
 
+	if ((skb->ip_summed == CHECKSUM_NONE) ||
+	    (skb->ip_summed == CHECKSUM_UNNECESSARY))
+		goto do_send;
+
 	rndis_msg_size += NDIS_CSUM_PPI_SIZE;
 	ppi = init_ppi_data(rndis_msg, NDIS_CSUM_PPI_SIZE,
 			    TCPIP_CHKSUM_PKTINFO);
-- 
1.7.4.1
