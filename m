From: Rob Herring <robh@kernel.org>
Subject: Re: [PATCH v5 2/4] Documentation: Bindings: Add STM32 DWMAC glue
Date: Mon, 21 Mar 2016 07:40:43 -0500
Message-ID: <20160321124043.GA26873@rob-hp-laptop>
References: <1458315428-10081-1-git-send-email-alexandre.torgue@gmail.com>
 <1458315428-10081-3-git-send-email-alexandre.torgue@gmail.com>
 <CAGb2v65SvVi0cJbaaD9cYrqC3pJ9eumwhTVk11_N7r_nTZhS9g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alexandre TORGUE <alexandre.torgue@gmail.com>,
	Maxime Coquelin <mcoquelin.stm32@gmail.com>,
	Giuseppe Cavallaro <peppe.cavallaro@st.com>,
	netdev <netdev@vger.kernel.org>,
	devicetree <devicetree@vger.kernel.org>,
	Joachim Eastwood <manabian@gmail.com>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	linux-arm-kernel <linux-arm-kernel@lists.infradead.org>
To: Chen-Yu Tsai <wens@csie.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CAGb2v65SvVi0cJbaaD9cYrqC3pJ9eumwhTVk11_N7r_nTZhS9g@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Mar 19, 2016 at 12:00:22AM +0800, Chen-Yu Tsai wrote:
> Hi,
> 
> On Fri, Mar 18, 2016 at 11:37 PM, Alexandre TORGUE
> <alexandre.torgue@gmail.com> wrote:
> > Signed-off-by: Alexandre TORGUE <alexandre.torgue@gmail.com>
> >
> > diff --git a/Documentation/devicetree/bindings/net/stm32-dwmac.txt b/Documentation/devicetree/bindings/net/stm32-dwmac.txt
> > new file mode 100644
> > index 0000000..ada2aa4
> > --- /dev/null
> > +++ b/Documentation/devicetree/bindings/net/stm32-dwmac.txt
> > @@ -0,0 +1,32 @@
> > +STMicroelectronics STM32 / MCU DWMAC glue layer controller
> > +
> > +This file documents platform glue layer for stmmac.
> > +Please see stmmac.txt for the other unchanged properties.
> > +
> > +The device node has following properties.
> > +
> > +Required properties:
> > +- compatible:  Should be "st,stm32-dwmac" to select glue, and
> > +              "snps,dwmac-3.50a" to select IP vesrion.
> 
> If you need have sort of hardware glue, then it is not compatible.

Hence, the more specific compatible. Having the generic one is still 
useful.

> 
> ChenYu
> 
> > +- clocks: Must contain a phandle for each entry in clock-names.
> > +- clock-names: Should be "stmmaceth" for the host clock.

This doesn't sound like the clock input signal name...

> > +              Should be "tx-clk" for the MAC TX clock.
> > +              Should be "rx-clk" for the MAC RX clock.

How can other DWMAC blocks not have these clocks? The glue can't really 
add these clocks. It could combine them into one or a new version of 
DWMAC could have a different number of clock inputs. So if there is 
variation here, then some of the bindings are probably wrong. I guess 
the only change I'm suggesting is possibly moving these into common 
binding doc.

> > +- st,syscon : Should be phandle/offset pair. The phandle to the syscon node which
> > +             encompases the glue register, and the offset of the control register.
> > +Example:
> > +
> > +               ethernet0: dwmac@40028000 {

ethernet@...

> > +                       compatible = "st,stm32-dwmac", "snps,dwmac-3.50a";
> > +                       status = "disabled";
> > +                       reg = <0x40028000 0x8000>;
> > +                       reg-names = "stmmaceth";
> > +                       interrupts = <0 61 0>, <0 62 0>;
> > +                       interrupt-names = "macirq", "eth_wake_irq";
> > +                       clock-names = "stmmaceth", "tx-clk", "rx-clk";
> > +                       clocks = <&rcc 0 25>, <&rcc 0 26>, <&rcc 0 27>;
> > +                       st,syscon = <&syscfg 0x4>;
> > +                       snps,pbl = <8>;
> > +                       snps,mixed-burst;
> > +                       dma-ranges;
> > +               };
> > --
> > 1.9.1
> >
> >
> > _______________________________________________
> > linux-arm-kernel mailing list
> > linux-arm-kernel@lists.infradead.org
> > http://lists.infradead.org/mailman/listinfo/linux-arm-kernel
> --
> To unsubscribe from this list: send the line "unsubscribe devicetree" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
