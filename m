From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [RFC 08/15] rtc: at91sam9: Add missing MFD_SYSCON dependency on
 HAS_IOMEM
Date: Thu, 03 Mar 2016 11:55:42 +0100
Message-ID: <2233190.1BxevBAvDE@wuerfel>
References: <1456992221-26712-1-git-send-email-k.kozlowski@samsung.com>
 <1456992221-26712-9-git-send-email-k.kozlowski@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Krzysztof Kozlowski <k.kozlowski@samsung.com>,
 Linus Walleij <linus.walleij@linaro.org>, linux-kernel@vger.kernel.org,
 David Brown <david.brown@linaro.org>,
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
 Dan Williams <dan.j.williams@intel.com>,
To: linux-arm-kernel@lists.infradead.org
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <1456992221-26712-9-git-send-email-k.kozlowski@samsung.com>
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

On Thursday 03 March 2016 17:03:34 Krzysztof Kozlowski wrote:
> index 0da40e2e4280..5c530b6b125d 100644
> --- a/drivers/rtc/Kconfig
> +++ b/drivers/rtc/Kconfig
> @@ -1302,6 +1302,7 @@ config RTC_DRV_AT91RM9200
>  config RTC_DRV_AT91SAM9
>         tristate "AT91SAM9 RTT as RTC"
>         depends on ARCH_AT91 || COMPILE_TEST
> +       depends on HAS_IOMEM    # For MFD_SYSCON
>         select MFD_SYSCON
>         help
>           Some AT91SAM9 SoCs provide an RTT (Real Time Timer) block which
> 

This is technically correct, but the entire RTC menu is hidden
inside of 'depends on !UML && !S390', so we won't ever get there
on any configuration that does not use HAS_IOMEM.

If we did, all other RTC drivers would also fail.

	Arnd
