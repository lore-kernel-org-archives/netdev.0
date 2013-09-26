From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: [PATCH 28/51] DMA-API: sound: fix dma mask handling in a lot
 of drivers
Date: Thu, 26 Sep 2013 08:54:25 +0100
Message-ID: <20130926075425.GX25647@n2100.arm.linux.org.uk>
References: <20130919212235.GD12758@n2100.arm.linux.org.uk>
 <E1VMm9m-0007ij-ER@rmk-PC.arm.linux.org.uk> <s5h1u4cf2bo.wl%tiwai@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: alsa-devel@alsa-project.org, linux-doc@vger.kernel.org,
 linux-mmc@vger.kernel.org, linux-fbdev@vger.kernel.org,
 linux-nvme@lists.infradead.org, Jaroslav Kysela <perex@perex.cz>,
 Peter Ujfalusi <peter.ujfalusi@ti.com>, linux-ide@vger.kernel.org,
 Kukjin Kim <kgene.kim@samsung.com>, devel@driverdev.osuosl.org,
 linux-samsung-soc@vger.kernel.org, linux-scsi@vger.kernel.org,
 e1000-devel@lists.sourceforge.net, b43-dev@lists.infradead.org,
 linux-media@vger.kernel.org, devicetree@vger.kernel.org,
 Haojian Zhuang <haojian.zhuang@gmail.com>, Timur Tabi <timur@tabi.org>,
 Mark Brown <broonie@kernel.org>, dri-devel@lists.freedesktop.org,
 Ben Dooks <ben-linux@fluff.org>, linux-tegra@vger.kernel.org,
 linux-omap@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
 Solarflare linux maintainers <linux-net-drivers@solarflare.com>,
 Eric Miao <eric.y.miao@gmail.com>, Sangbeom Kim <sbkim73@sa
To: Takashi Iwai <tiwai@suse.de>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
Content-Disposition: inline
In-Reply-To: <s5h1u4cf2bo.wl%tiwai@suse.de>
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

On Thu, Sep 26, 2013 at 09:51:23AM +0200, Takashi Iwai wrote:
> Hi,
> 
> sorry for the lat response, as I've been traveling in the last weeks.
> 
> At Thu, 19 Sep 2013 22:53:02 +0100,
> Russell King wrote:
> > 
> > This code sequence is unsafe in modules:
> > 
> > static u64 mask = DMA_BIT_MASK(something);
> > ...
> > 	if (!dev->dma_mask)
> > 		dev->dma_mask = &mask;
> > 
> > as if a module is reloaded, the mask will be pointing at the original
> > module's mask address, and this can lead to oopses.  Moreover, they
> > all follow this with:
> > 
> > 	if (!dev->coherent_dma_mask)
> > 		dev->coherent_dma_mask = mask;
> > 
> > where 'mask' is the same value as the statically defined mask, and this
> > bypasses the architecture's check on whether the DMA mask is possible.
> > 
> > Fix these issues by using the new dma_coerce_coherent_and_mask()
> > function.
> > 
> > Signed-off-by: Russell King <rmk+kernel@arm.linux.org.uk>
> 
> Applied with Mark's ack now.

Which is a very stupid thing to do because you won't have
dma_coerce_coherent_and_mask() in your tree, so all these drivers
will fail to build for you.
