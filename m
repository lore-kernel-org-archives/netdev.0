From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH V3 2/8] net: sxgbe: add basic framework for Samsung 10Gb
 ethernet driver
Date: Mon, 17 Mar 2014 14:35:56 -0700
Message-ID: <1395092156.2556.56.camel@joe-AO722>
References: <00bf01cf4221$95373150$bfa593f0$@samsung.com>
	 <20140317.171825.1118518563919818497.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: bh74.an@samsung.com, netdev@vger.kernel.org,
	linux-samsung-soc@vger.kernel.org, siva.kallam@samsung.com,
	vipul.pandya@samsung.com, ks.giri@samsung.com,
	ilho215.lee@samsung.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0078.hostedemail.com ([216.40.44.78]:50489 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1750706AbaCQVgA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Mar 2014 17:36:00 -0400
In-Reply-To: <20140317.171825.1118518563919818497.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2014-03-17 at 17:18 -0400, David Miller wrote:
> From: Byungho An <bh74.an@samsung.com>
> Date: Mon, 17 Mar 2014 13:43:37 -0700
> 
> > +static void sxgbe_tx_timer(unsigned long data)
> > +{
> > +	struct sxgbe_tx_queue *p = (struct sxgbe_tx_queue *)data;
> > +	sxgbe_tx_queue_clean(p);
> > +}
> 
> A empty line after local variable declarations please.
[]
> Please audit your entire submission for this problem.

Hi again Byungho An (and all the other Samsung folk)

I suggest using scripts/checkpatch.pl --strict from linux-next.
It flags (imperfectly) a lot of these things.

I would ignore the Non-standard signature, CamelCase and the
long line warnings, but I suppose the rest could be improved.

I get:

WARNING: Non-standard signature: Neatening-by:
#99: 
Neatening-by: Joe Perches <joe@perches.com>

CHECK: Avoid CamelCase: <BUF_SIZE_16KiB>
#292: FILE: drivers/net/ethernet/samsung/sxgbe/sxgbe_common.h:55:
+#define BUF_SIZE_16KiB 16384

CHECK: Avoid CamelCase: <BUF_SIZE_8KiB>
#293: FILE: drivers/net/ethernet/samsung/sxgbe/sxgbe_common.h:56:
+#define BUF_SIZE_8KiB 8192

CHECK: Avoid CamelCase: <BUF_SIZE_4KiB>
#294: FILE: drivers/net/ethernet/samsung/sxgbe/sxgbe_common.h:57:
+#define BUF_SIZE_4KiB 4096

CHECK: Avoid CamelCase: <BUF_SIZE_2KiB>
#295: FILE: drivers/net/ethernet/samsung/sxgbe/sxgbe_common.h:58:
+#define BUF_SIZE_2KiB 2048

CHECK: spinlock_t definition without comment
#560: FILE: drivers/net/ethernet/samsung/sxgbe/sxgbe_common.h:323:
+	spinlock_t tx_lock;

CHECK: spinlock_t definition without comment
#644: FILE: drivers/net/ethernet/samsung/sxgbe/sxgbe_common.h:407:
+	spinlock_t stats_lock;

WARNING: line over 80 characters
#2474: FILE: drivers/net/ethernet/samsung/sxgbe/sxgbe_main.c:304:
+					      tx_rsize * sizeof(struct sxgbe_tx_norm_desc),

WARNING: line over 80 characters
#2562: FILE: drivers/net/ethernet/samsung/sxgbe/sxgbe_main.c:392:
+					      rx_rsize * sizeof(struct sxgbe_rx_norm_desc),

WARNING: line over 80 characters
#2575: FILE: drivers/net/ethernet/samsung/sxgbe/sxgbe_main.c:405:
+					   sizeof(struct sk_buff *), GFP_KERNEL);

WARNING: line over 80 characters
#2740: FILE: drivers/net/ethernet/samsung/sxgbe/sxgbe_main.c:570:
+						    sizeof(struct sxgbe_tx_queue), GFP_KERNEL);

WARNING: line over 80 characters
#2757: FILE: drivers/net/ethernet/samsung/sxgbe/sxgbe_main.c:587:
+						    sizeof(struct sxgbe_rx_queue), GFP_KERNEL);

WARNING: line over 80 characters
#2854: FILE: drivers/net/ethernet/samsung/sxgbe/sxgbe_main.c:684:
+		     sxgbe_tx_avail(tqueue, tx_rsize) > SXGBE_TX_THRESH(priv))) {

WARNING: Missing a blank line after declarations
#3355: FILE: drivers/net/ethernet/samsung/sxgbe/sxgbe_main.c:1185:
+		int len = skb_frag_size(frag);
+		entry = (++tqueue->cur_tx) % tx_rsize;

WARNING: line over 80 characters
#3542: FILE: drivers/net/ethernet/samsung/sxgbe/sxgbe_main.c:1372:
+						    struct sxgbe_priv_data, napi);

WARNING: line over 80 characters
#3669: FILE: drivers/net/ethernet/samsung/sxgbe/sxgbe_main.c:1499:
+						   struct rtnl_link_stats64 *stats)

WARNING: line over 80 characters
#3699: FILE: drivers/net/ethernet/samsung/sxgbe/sxgbe_main.c:1529:
+					       SXGBE_MMC_RXFIFOOVERFLOWHI_GBCNT_REG));

CHECK: __setup appears un-documented -- check Documentation/kernel-parameters.txt
#4229: FILE: drivers/net/ethernet/samsung/sxgbe/sxgbe_main.c:2059:
+__setup("sxgbeeth=", sxgbe_cmdline_opt);

WARNING: Missing a blank line after declarations
#4556: FILE: drivers/net/ethernet/samsung/sxgbe/sxgbe_mtl.c:27:
+	u32 reg_val;
+	reg_val = readl(ioaddr + SXGBE_MTL_OP_MODE_REG);

WARNING: Missing a blank line after declarations
#4617: FILE: drivers/net/ethernet/samsung/sxgbe/sxgbe_mtl.c:88:
+	u32 reg_val;
+	reg_val = readl(ioaddr + SXGBE_MTL_TXQ_OPMODE_REG(queue_num));

WARNING: Missing a blank line after declarations
#4625: FILE: drivers/net/ethernet/samsung/sxgbe/sxgbe_mtl.c:96:
+	u32 reg_val;
+	reg_val = readl(ioaddr + SXGBE_MTL_TXQ_OPMODE_REG(queue_num));

WARNING: Missing a blank line after declarations
#4634: FILE: drivers/net/ethernet/samsung/sxgbe/sxgbe_mtl.c:105:
+	u32 reg_val;
+	reg_val = readl(ioaddr + SXGBE_MTL_RXQ_OPMODE_REG(queue_num));

WARNING: Missing a blank line after declarations
#4644: FILE: drivers/net/ethernet/samsung/sxgbe/sxgbe_mtl.c:115:
+	u32 reg_val;
+	reg_val = readl(ioaddr + SXGBE_MTL_RXQ_OPMODE_REG(queue_num));

WARNING: Missing a blank line after declarations
#4653: FILE: drivers/net/ethernet/samsung/sxgbe/sxgbe_mtl.c:124:
+	u32 reg_val;
+	reg_val = readl(ioaddr + SXGBE_MTL_RXQ_OPMODE_REG(queue_num));

WARNING: Missing a blank line after declarations
#4663: FILE: drivers/net/ethernet/samsung/sxgbe/sxgbe_mtl.c:134:
+	u32 reg_val;
+	reg_val = readl(ioaddr + SXGBE_MTL_RXQ_OPMODE_REG(queue_num));

WARNING: Missing a blank line after declarations
#4672: FILE: drivers/net/ethernet/samsung/sxgbe/sxgbe_mtl.c:143:
+	u32 reg_val;
+	reg_val = readl(ioaddr + SXGBE_MTL_RXQ_OPMODE_REG(queue_num));

WARNING: Missing a blank line after declarations
#4681: FILE: drivers/net/ethernet/samsung/sxgbe/sxgbe_mtl.c:152:
+	u32 reg_val;
+	reg_val = readl(ioaddr + SXGBE_MTL_RXQ_OPMODE_REG(queue_num));

WARNING: Missing a blank line after declarations
#4690: FILE: drivers/net/ethernet/samsung/sxgbe/sxgbe_mtl.c:161:
+	u32 reg_val;
+	reg_val = readl(ioaddr + SXGBE_MTL_RXQ_OPMODE_REG(queue_num));

WARNING: Missing a blank line after declarations
#4732: FILE: drivers/net/ethernet/samsung/sxgbe/sxgbe_mtl.c:203:
+	u32 reg_val;
+	reg_val = readl(ioaddr + SXGBE_MTL_RXQ_OPMODE_REG(queue_num));

WARNING: DT compatible string "samsung,sxgbe-v2.0a" appears un-documented -- check ./Documentation/devicetree/bindings/
#5115: FILE: drivers/net/ethernet/samsung/sxgbe/sxgbe_platform.c:229:
+	{ .compatible = "samsung,sxgbe-v2.0a"},

total: 0 errors, 25 warnings, 7 checks, 5555 lines checked
