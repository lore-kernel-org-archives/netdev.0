From: SF Markus Elfring <elfring@users.sourceforge.net>
Subject: [PATCH 05/25] net: mvpp2: Use kmalloc_array() in mvpp2_txq_init()
Date: Mon, 17 Apr 2017 17:15:26 +0200
Message-ID: <f9948035-e150-d622-e702-a59256d7d5e6@users.sourceforge.net>
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
Date: Mon, 17 Apr 2017 08:09:07 +0200

* A multiplication for the size determination of a memory allocation
  indicated that an array data structure should be processed.
  Thus use the corresponding function "kmalloc_array".

  This issue was detected by using the Coccinelle software.

* Replace the specification of a data structure by a pointer dereference
  to make the corresponding size determination a bit safer according to
  the Linux coding style convention.

Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>
---
 drivers/net/ethernet/marvell/mvpp2.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/marvell/mvpp2.c b/drivers/net/ethernet/marvell/mvpp2.c
index af5bfa13d976..a86d9111c476 100644
--- a/drivers/net/ethernet/marvell/mvpp2.c
+++ b/drivers/net/ethernet/marvell/mvpp2.c
@@ -5083,9 +5083,9 @@ static int mvpp2_txq_init(struct mvpp2_port *port,
 	for_each_present_cpu(cpu) {
 		txq_pcpu = per_cpu_ptr(txq->pcpu, cpu);
 		txq_pcpu->size = txq->size;
-		txq_pcpu->buffs = kmalloc(txq_pcpu->size *
-					  sizeof(struct mvpp2_txq_pcpu_buf),
-					  GFP_KERNEL);
+		txq_pcpu->buffs = kmalloc_array(txq_pcpu->size,
+						sizeof(*txq_pcpu->buffs),
+						GFP_KERNEL);
 		if (!txq_pcpu->buffs)
 			goto error;
 
-- 
2.12.2
