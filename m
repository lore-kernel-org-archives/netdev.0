From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [rtc-linux] Re: [RFC 09/15] media: platform: Add missing
 MFD_SYSCON dependency on HAS_IOMEM
Date: Thu, 03 Mar 2016 14:05:33 +0100
Message-ID: <13054519.5feSCc5dgv@wuerfel>
References: <1456992221-26712-1-git-send-email-k.kozlowski@samsung.com>
 <2181866.k24LVvUjTs@wuerfel>
 <CAJKOXPe50ira_Qqy7qJ5H_PHa8B_xOinCK6JkncXFYn_eaQFfg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Krzysztof Kozlowski <k.kozlowski@samsung.com>,
 Linus Walleij <linus.walleij@linaro.org>, linux-kernel@vger.kernel.org,
 David Brown <david.brown@linaro.org>, netdev@vger.kernel.org,
 Alexandre Belloni <alexandre.belloni@free-electrons.com>,
 Laurent Pinchart <laurent.pinchart@ideasonboard.com>,
 Lee Jones <lee.jones@linaro.org>, Thomas Gleixner <tglx@linutronix.de>,
 devel@driverdev.osuosl.org, linux-samsung-soc@vger.kernel.org,
 Vinod Koul <vinod.koul@intel.com>, Daniel Lezcano <daniel.lezcano@linaro.org>,
 Kishon Vijay Abraham I <kishon@ti.com>, Andy Gross <andy.gross@linaro.org>,
 linux-media@vger.kernel.org, Jason Cooper <jason@lakedaemon.net>,
 rtc-linux@googlegroups.com, Mauro Carvalho Chehab <mchehab@osg.samsung.com>,
 Marc Zyngier <marc.zyngier@arm.com>, linux-arm-msm@vger.kernel.org,
 linux-gpio@vger.kernel.org, Giuseppe Cavallaro <peppe.cavallaro@st.com>,
 Dan Williams <da
To: linux-arm-kernel@lists.infradead.org
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <CAJKOXPe50ira_Qqy7qJ5H_PHa8B_xOinCK6JkncXFYn_eaQFfg@mail.gmail.com>
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

On Thursday 03 March 2016 21:40:23 Krzysztof Kozlowski wrote:
> >>         select MFD_SYSCON
> >> diff --git a/drivers/media/platform/exynos4-is/Kconfig b/drivers/media/platform/exynos4-is/Kconfig
> >> index 57d42c6172c5..c4317b99d257 100644
> >> --- a/drivers/media/platform/exynos4-is/Kconfig
> >> +++ b/drivers/media/platform/exynos4-is/Kconfig
> >> @@ -17,6 +17,7 @@ config VIDEO_S5P_FIMC
> >>         tristate "S5P/EXYNOS4 FIMC/CAMIF camera interface driver"
> >>         depends on I2C
> >>         depends on HAS_DMA
> >> +       depends on HAS_IOMEM    # For MFD_SYSCON
> >>         select VIDEOBUF2_DMA_CONTIG
> >>         select V4L2_MEM2MEM_DEV
> >
> > This  is guarded by HAS_DMA, which implies HAS_IOMEM afaik.
> 
> Looking at Kconfigs - no, it is not implied (or am I missing
> something)... and sometimes dependency on HAS_IOMEM is next to
> HAS_DMA.
> 
> 

Ah, you are right: UML has no DMA and no IOMEM, but s390 can
have IOMEM (if PCI is enabled) and always sets HAS_DMA.

In practice, I think the HAS_DMA symbol is not as well-defined
as it should be, it basically refers to the presence of the dma-mapping.h
API, and that only really makes sense when you also have IOMEM,
so there might be an implied dependency between the two, but it's
not enforced or actually true.

	Arnd
