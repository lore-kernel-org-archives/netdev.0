From: Peter Senna Tschudin <peter.senna@gmail.com>
Subject: [PATCH 3/20] drivers/net/can/sja1000/peak_pci.c: fix error return code
Date: Wed,  3 Oct 2012 18:17:54 +0200
Message-ID: <1349281090-10013-4-git-send-email-peter.senna@gmail.com>
Cc: kernel-janitors@vger.kernel.org, mkl@pengutronix.de,
	davem@davemloft.net, jj@chaosbits.net, linux-can@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: wg@grandegger.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Peter Senna Tschudin <peter.senna@gmail.com>

Convert a nonnegative error return code to a negative one, as returned
elsewhere in the function.

A simplified version of the semantic match that finds this problem is as
follows: (http://coccinelle.lip6.fr/)

// <smpl>
(
if@p1 (\(ret < 0\|ret != 0\))
 { ... return ret; }
|
ret@p1 = 0
)
... when != ret = e1
    when != &ret
*if(...)
{
  ... when != ret = e2
      when forall
 return ret;
}
// </smpl>

Signed-off-by: Peter Senna Tschudin <peter.senna@gmail.com>

---
 drivers/net/can/sja1000/peak_pci.c |    2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/can/sja1000/peak_pci.c b/drivers/net/can/sja1000/peak_pci.c
index f0a1296..f5b82ae 100644
--- a/drivers/net/can/sja1000/peak_pci.c
+++ b/drivers/net/can/sja1000/peak_pci.c
@@ -583,12 +583,14 @@ static int __devinit peak_pci_probe(struct pci_dev *pdev,
 	cfg_base = pci_iomap(pdev, 0, PEAK_PCI_CFG_SIZE);
 	if (!cfg_base) {
 		dev_err(&pdev->dev, "failed to map PCI resource #0\n");
+		err = -ENOMEM;
 		goto failure_release_regions;
 	}
 
 	reg_base = pci_iomap(pdev, 1, PEAK_PCI_CHAN_SIZE * channels);
 	if (!reg_base) {
 		dev_err(&pdev->dev, "failed to map PCI resource #1\n");
+		err = -ENOMEM;
 		goto failure_unmap_cfg_base;
 	}
 
