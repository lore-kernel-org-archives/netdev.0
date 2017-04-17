From: SF Markus Elfring <elfring@users.sourceforge.net>
Subject: [PATCH 01/25] net: mvneta: Use devm_kmalloc_array() in mvneta_init()
Date: Mon, 17 Apr 2017 17:08:29 +0200
Message-ID: <c97b4f03-f596-687a-ad28-3216185260a4@users.sourceforge.net>
References: <d6f26bba-c678-5b66-4f5d-85f56d895190@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>,
        kernel-janitors@vger.kernel.org
To: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Jarod Wilson <jarod@redhat.com>,
        Jisheng Zhang <jszhang@marvell.com>,
        Mirko Lindner <mlindner@marvell.com>,
        Philippe Reynes <tremyfr@gmail.com>,
        Russell King <rmk+kernel@armlinux.org.uk>,
        Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
        Stephen Hemminger <stephen@networkplumber.org>,
        Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <d6f26bba-c678-5b66-4f5d-85f56d895190@users.sourceforge.net>
Content-Language: en-GB
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Markus Elfring <elfring@users.sourceforge.net>
Date: Sun, 16 Apr 2017 21:23:19 +0200

* A multiplication for the size determination of a memory allocation
  indicated that an array data structure should be processed.
  Thus use the corresponding function "devm_kmalloc_array".

  This issue was detected by using the Coccinelle software.

* Replace the specification of a data type by a pointer dereference
  to make the corresponding size determination a bit safer according to
  the Linux coding style convention.

Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>
---
 drivers/net/ethernet/marvell/mvneta.c | 8 +++++---
 1 file changed, 5 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/marvell/mvneta.c b/drivers/net/ethernet/marvell/mvneta.c
index 34a3686d2ce6..46fa74e93814 100644
--- a/drivers/net/ethernet/marvell/mvneta.c
+++ b/drivers/net/ethernet/marvell/mvneta.c
@@ -4017,9 +4017,11 @@ static int mvneta_init(struct device *dev, struct mvneta_port *pp)
 		rxq->size = pp->rx_ring_size;
 		rxq->pkts_coal = MVNETA_RX_COAL_PKTS;
 		rxq->time_coal = MVNETA_RX_COAL_USEC;
-		rxq->buf_virt_addr = devm_kmalloc(pp->dev->dev.parent,
-						  rxq->size * sizeof(void *),
-						  GFP_KERNEL);
+		rxq->buf_virt_addr
+			= devm_kmalloc_array(pp->dev->dev.parent,
+					     rxq->size,
+					     sizeof(*rxq->buf_virt_addr),
+					     GFP_KERNEL);
 		if (!rxq->buf_virt_addr)
 			return -ENOMEM;
 	}
-- 
2.12.2
