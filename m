From: Jisheng Zhang <jszhang@marvell.com>
Subject: Re: [PATCH 3/4] net: mvneta: mmc: get optional axi clk
Date: Wed, 20 Jan 2016 16:53:19 +0800
Message-ID: <20160120165319.5ee8589a@xhacker>
References: <1453277183-5412-1-git-send-email-jszhang@marvell.com>
 <1453277183-5412-4-git-send-email-jszhang@marvell.com>
 <20160120095132.29896293@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: mark.rutland@arm.com, devicetree@vger.kernel.org, pawel.moll@arm.com,
 ijc+devicetree@hellion.org.uk, netdev@vger.kernel.org,
 linux-kernel@vger.kernel.org, robh+dt@kernel.org, galak@codeaurora.org,
 mw@semihalf.com, davem@davemloft.net, linux-arm-kernel@lists.infradead.org,
 sebastian.hesselbarth@gmail.com
To: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <20160120095132.29896293@free-electrons.com>
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

On Wed, 20 Jan 2016 09:51:32 +0100 Thomas Petazzoni wrote:

> Dear Jisheng Zhang,
> 
> On Wed, 20 Jan 2016 16:06:22 +0800, Jisheng Zhang wrote:
> > Some platforms may provide more than one clk for the mvneta IP, for
> > example Marvell BG4CT provides "core" clk for the mac core, and
> > "axi" clk for the AXI bus logic. Obviously this "axi" clk also need to
> > be enabled. This patch adds this optional "axi" clk support.
> > 
> > Signed-off-by: Jisheng Zhang <jszhang@marvell.com>  
> 
> Typo in the title, you have "mmc: ", while this patch is not related to
> MMC, unless I'm missing something and MMC means something else in this
> context.

oops, thanks for pointing out this.

> 
> >  	clk_prepare_enable(pp->clk);
> >  
> > +	pp->clk_axi = devm_clk_get(&pdev->dev, "axi");
> > +	if (!IS_ERR(pp->clk_axi))
> > +		clk_prepare_enable(pp->clk_axi);
> > +
> >  	res = platform_get_resource(pdev, IORESOURCE_MEM, 0);
> >  	pp->base = devm_ioremap_resource(&pdev->dev, res);
> >  	if (IS_ERR(pp->base)) {
> > @@ -3727,6 +3733,7 @@ err_free_ports:
> >  	free_percpu(pp->ports);
> >  err_clk:
> >  	clk_disable_unprepare(pp->clk);
> > +	clk_disable_unprepare(pp->clk_axi);  
> 
> For the error paths and cleanup steps, I very much prefer when things
> are done in the opposite order of the allocation/creation steps. So can
> you clk_disable_unprepare() the AXI clock before the core clock ?

Both are fine. But I agree with your prefer. Will cook a v2 soon

Thanks for reviewing.

> 
> >  err_put_phy_node:
> >  	of_node_put(phy_node);
> >  err_free_irq:
> > @@ -3744,6 +3751,7 @@ static int mvneta_remove(struct platform_device *pdev)
> >  
> >  	unregister_netdev(dev);
> >  	clk_disable_unprepare(pp->clk);
> > +	clk_disable_unprepare(pp->clk_axi);  
> 
> Ditto.
> 
> Thanks!
> 
> Thomas
