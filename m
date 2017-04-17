From: SF Markus Elfring <elfring@users.sourceforge.net>
Subject: [PATCH 06/25] net: mvpp2: Improve two size determinations in
 mvpp2_probe()
Date: Mon, 17 Apr 2017 17:16:20 +0200
Message-ID: <c745ed5e-9b8e-6aeb-9faf-27a8ddd7544a@users.sourceforge.net>
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
Date: Mon, 17 Apr 2017 08:38:32 +0200

Replace the specification of two data structures by pointer dereferences
as the parameter for the operator "sizeof" to make the corresponding size
determination a bit safer according to the Linux coding style convention.

Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>
---
 drivers/net/ethernet/marvell/mvpp2.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/marvell/mvpp2.c b/drivers/net/ethernet/marvell/mvpp2.c
index a86d9111c476..04aba2307b60 100644
--- a/drivers/net/ethernet/marvell/mvpp2.c
+++ b/drivers/net/ethernet/marvell/mvpp2.c
@@ -6873,7 +6873,7 @@ static int mvpp2_probe(struct platform_device *pdev)
 	int port_count, cpu;
 	int err;
 
-	priv = devm_kzalloc(&pdev->dev, sizeof(struct mvpp2), GFP_KERNEL);
+	priv = devm_kzalloc(&pdev->dev, sizeof(*priv), GFP_KERNEL);
 	if (!priv)
 		return -ENOMEM;
 
@@ -6970,8 +6970,8 @@ static int mvpp2_probe(struct platform_device *pdev)
 	}
 
 	priv->port_list = devm_kcalloc(&pdev->dev, port_count,
-				      sizeof(struct mvpp2_port *),
-				      GFP_KERNEL);
+				       sizeof(*priv->port_list),
+				       GFP_KERNEL);
 	if (!priv->port_list) {
 		err = -ENOMEM;
 		goto err_mg_clk;
-- 
2.12.2
