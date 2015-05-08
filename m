From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH RFC 0/2] stmmac: stand alone platform drivers
Date: Fri, 08 May 2015 15:30:50 +0200
Message-ID: <5987007.lq0DjS0tE0@wuerfel>
References: <1431022765-30715-1-git-send-email-manabian@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: peppe.cavallaro@st.com, Joachim Eastwood <manabian@gmail.com>,
 davem@davemloft.net, netdev@vger.kernel.org
To: linux-arm-kernel@lists.infradead.org
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <1431022765-30715-1-git-send-email-manabian@gmail.com>
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

On Thursday 07 May 2015 20:19:23 Joachim Eastwood wrote:
> Hi Arnd,
> 
> I ran into some issue using a separate platform driver[1] for lpc1850-dwmac.
> 
> My dts files looks like this.
> mac: ethernet@40010000 {
>         compatible = "nxp,lpc1850-dwmac", "snps,dwmac-3.611", "snps,dwmac";
>         ...
> }
> 
> On boot the generic driver in stmmac_platform.c would grab the
> device, matching on one of generic compat strings and thus blocking
> the lpc1850-dwmac driver.
> 
> By changing the build order in the Makefile (see patch 1) I managed
> to get it working, but I am not sure that is a good solution(?).

Changing the link order in the Makefile is an acceptable solution
for managing initialization order in general, but I think it won't
work here, because if your driver is a loadable module, the base
driver would always be attached first.
 
> Another fix would be to remove the generic compat strings from the
> match table in stmmac_platform but there are some dts-files that
> only have these compat strings.
> See abilis_tb10x.dtsi and exynos5440.dtsi.

Yes, that has a high risk of causing regressions.

> I could also remove the generic compat strings from my dts file but
> I am not sure that is good solution either. If more glue is
> converted this would then be need in those dts files also.

I think it would work if you move the generic strings into a separate
module that is not the one providing the base support. In that case,
the kernel should first try to use the driver that matches the first
compatible string. Can you try that?

	Arnd
