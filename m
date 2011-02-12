From: Jean-Christophe PLAGNIOL-VILLARD <plagnioj@jcrosoft.com>
Subject: Re: [PATCH 1/2] atmel/macb: fix device name when SOFT/HARD_IRQ enabled
Date: Sat, 12 Feb 2011 15:30:00 +0100
Message-ID: <20110212143000.GH11255@game.jcrosoft.org>
References: <1297255416-6920-1-git-send-email-plagnioj@jcrosoft.com>
	<4D529992.7050502@ru.mvista.com>
	<20110209144411.GB11255@game.jcrosoft.org>
	<4D53EEFA.3030801@ru.mvista.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Nicolas Ferre <nicolas.ferre@atmel.com>,
	linux-arm-kernel@lists.infradead.org, Paul Chavent <paul.chavent@fnac.net>
To: Sergei Shtylyov <sshtylyov@mvista.com>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
Content-Disposition: inline
In-Reply-To: <4D53EEFA.3030801@ru.mvista.com>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
	<mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
	<mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: linux-arm-kernel-bounces@lists.infradead.org
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

On 16:58 Thu 10 Feb     , Sergei Shtylyov wrote:
> Hello.
> 
> On 09-02-2011 17:44, Jean-Christophe PLAGNIOL-VILLARD wrote:
> 
> >>>From: Paul Chavent<paul.chavent@fnac.net>
> 
> >>>When listing processes on a system with SOFT/HARD_IRQ enabled,
> >>>the name of the ethernet device is [irq/eth%d] (instead of [irq/eth0] for example).
> 
> >>>This patch call the request_irq function after having initialized the name of the device.
> 
> >>>Signed-off-by: Paul Chavent<paul.chavent@fnac.net>
> >>>Signed-off-by: Nicolas Ferre<nicolas.ferre@atmel.com>
> >>>Signed-off-by: Jean-Christophe PLAGNIOL-VILLARD<plagnioj@jcrosoft.com>
> >>[...]
> 
> >>>diff --git a/drivers/net/macb.c b/drivers/net/macb.c
> >>>index f69e73e..d642e08 100644
> >>>--- a/drivers/net/macb.c
> >>>+++ b/drivers/net/macb.c
> >>[...]
> >>>@@ -1219,13 +1209,23 @@ static int __init macb_probe(struct platform_device *pdev)
> >>>  	err = register_netdev(dev);
> >>>  	if (err) {
> >>>  		dev_err(&pdev->dev, "Cannot register net device, aborting.\n");
> >>>-		goto err_out_free_irq;
> >>>+		goto err_out_iounmap;
> >>>  	}
> >>>
> >>>-	if (macb_mii_init(bp) != 0) {
> >>>+	dev->irq = platform_get_irq(pdev, 0);
> 
> >>    platform_get_irq() can fail...
> 
> >request_irq will fail too so do we really need to check it?
> 
>    You then will get the following printed:
> 
> macb: Unable to request IRQ -6 (error -22)
> 
>    If this is acceptable, then platfrom_get_irq()'s result can be ignored indeed.
yes it's

Best Regards,
J.
