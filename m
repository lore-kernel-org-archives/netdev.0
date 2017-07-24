From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net-next 2/6] netvsc: Remove redundant use of ipv6_hdr()
Date: Mon, 24 Jul 2017 10:57:26 -0700
Message-ID: <20170724175730.31806-3-sthemmin@microsoft.com>
References: <20170724175730.31806-1-sthemmin@microsoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devel@linuxdriverproject.org, Mohammed Gamal <mgamal@redhat.com>,
 netdev@vger.kernel.org
To: kys@microsoft.com,
	haiyangz@microsoft.com,
	sthemmin@microsoft.com
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <20170724175730.31806-1-sthemmin@microsoft.com>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel/>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: "devel" <driverdev-devel-bounces@linuxdriverproject.org>
List-Id: netdev.vger.kernel.org

From: Mohammed Gamal <mgamal@redhat.com>

This condition already uses an object of type ipv6hdr in the line above.
Use the object directly instead of calling ipv6_hdr

Signed-off-by: Mohammed Gamal <mgamal@redhat.com>
---
 drivers/net/hyperv/netvsc_drv.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/hyperv/netvsc_drv.c b/drivers/net/hyperv/netvsc_drv.c
index 1238600d717e..bc2af352d6dd 100644
--- a/drivers/net/hyperv/netvsc_drv.c
+++ b/drivers/net/hyperv/netvsc_drv.c
@@ -339,7 +339,7 @@ static u32 net_checksum_info(struct sk_buff *skb)
 
 		if (ip6->nexthdr == IPPROTO_TCP)
 			return TRANSPORT_INFO_IPV6_TCP;
-		else if (ipv6_hdr(skb)->nexthdr == IPPROTO_UDP)
+		else if (ip6->nexthdr == IPPROTO_UDP)
 			return TRANSPORT_INFO_IPV6_UDP;
 	}
 
-- 
2.11.0
