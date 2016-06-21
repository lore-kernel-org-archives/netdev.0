From: Shawn Guo <shawnguo@kernel.org>
Subject: Re: [PATCH 1/2] ARM: imx6: disable deeper idle states when FEC is
 active w/o HW workaround
Date: Tue, 21 Jun 2016 10:40:18 +0800
Message-ID: <20160621024018.GA21364@tiger>
References: <1464794983-31484-1-git-send-email-l.stach@pengutronix.de>
 <1464794983-31484-2-git-send-email-l.stach@pengutronix.de>
 <4916175.LqH9s7UaP8@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devicetree@vger.kernel.org, Fugang Duan <fugang.duan@nxp.com>,
 netdev@vger.kernel.org, patchwork-lst@pengutronix.de, kernel@pengutronix.de,
 linux-arm-kernel@lists.infradead.org, Lucas Stach <l.stach@pengutronix.de>
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
Content-Disposition: inline
In-Reply-To: <4916175.LqH9s7UaP8@wuerfel>
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

On Thu, Jun 16, 2016 at 05:47:26PM +0200, Arnd Bergmann wrote:
> On Wednesday, June 1, 2016 5:29:42 PM CEST Lucas Stach wrote:
> > +/*
> > + * i.MX6 Q/DL has an erratum (ERR006687) that prevents the FEC from waking the
> > + * CPUs when they are in wait(unclocked) state. As the hardware workaround isn't
> > + * applicable to all boards, disable the deeper idle state when the workaround
> > + * isn't present and the FEC is in use.
> > + */
> > +void imx6q_cpuidle_fec_irqs_used(void)
> > +{
> > +       imx6q_cpuidle_driver.states[1].disabled = true;
> > +}
> > +
> > +void imx6q_cpuidle_fec_irqs_unused(void)
> > +{
> > +       imx6q_cpuidle_driver.states[1].disabled = false;
> > +}
> > +
> 
> These functions need to be exported, I just saw a build error in
> an allmodconfig test:
> 
> ERROR: "imx6q_cpuidle_fec_irqs_unused" [drivers/net/ethernet/freescale/fec.ko] undefined!
> ERROR: "imx6q_cpuidle_fec_irqs_used" [drivers/net/ethernet/freescale/fec.ko] undefined!

Thanks for the report, Arnd.  Just sent a fix for it.

Shawn
