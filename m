From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH v2 1/4] net: dt-bindings: Document the new Meson8b and
 GXBB DWMAC bindings
Date: Mon, 29 Aug 2016 15:31:12 +0200
Message-ID: <201608291531.12188.arnd@arndb.de>
References: <20160815164100.27766-1-martin.blumenstingl@googlemail.com>
 <4041259.IszN4229Cj@wuerfel>
 <CAFBinCDnHGf=wgvm9KzYQsf=kCrOUeO3bnEwdGy_OK-wgWkDug@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: mark.rutland@arm.com, devicetree@vger.kernel.org, alexandre.torgue@st.com,
 catalin.marinas@arm.com, mturquette@baylibre.com, sboyd@codeaurora.org,
 will.deacon@arm.com, robh+dt@kernel.org, khilman@baylibre.com,
 carlo@caione.org, peppe.cavallaro@st.com, linux-amlogic@lists.infradead.org,
 netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org
To: Martin Blumenstingl <martin.blumenstingl@googlemail.com>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <CAFBinCDnHGf=wgvm9KzYQsf=kCrOUeO3bnEwdGy_OK-wgWkDug@mail.gmail.com>
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

On Sunday 28 August 2016, Martin Blumenstingl wrote:
> On Mon, Aug 22, 2016 at 5:25 PM, Arnd Bergmann <arnd@arndb.de> wrote:
> > It really depends on the kind of SoC. Some may have a suboptimal
> > binding, on some others there may be a distinct register area that
> > just contains a few additional registers for the dwmac.
> the dwmac PHY configuration registers (2x32bit) on the GXBB SoC are
> part of the "periphs" region/module. This is already defined as
> "simple-bus" in meson-gxbb.dtsi, see [0]
> On Meson8b this is slightly different: there is no specific "periphs"
> region - there the dwmac PHY configuration registers are directly
> located in the cbus region at a slightly different offset than on the
> GXBB SoCs.
> 
> In the future we might need a third memory region because the latest
> reference kernel contains some more PHY configuration registers on
> newer SoCs (GXL = S905X).
> 
> Please let me know if you're OK with the dts definition in it's
> current state - or let me know how you would like to change it.
> 
> PS: I will re-send the patches in a v3 in a few minutes because that
> fixes a bug during module unload.

I don't really see a good way to describe this hardware then. If it
was only the first case, I'd suggest marking the periphs bus node
as "compatible="simple-bus","syscon";" so you could have a
reference to it, but that doesn't seem to work well in the second
case, unless you can a separate DT node just for the PHY config
registers there.

With the third case, is there any logic at all behind the
register map?

Maybe someone else has a better idea for how to describe this.
In general, we try to avoid overlapping "reg" properties, but I
even see that the "periphs" node  on gxbb has a "reg" property
(is this intentional) that overlaps with the registers in its
ranges, so adding another one won't make this worse than it
already is.

	Arnd
