From: Duc Dang <dhdang@apm.com>
Subject: Re: [PATCH v5 09/11] dtb: xgene: Add MDIO node
Date: Tue, 2 Aug 2016 12:10:28 -0700
Message-ID: <CADaLNDnizBfxXcy8_W2WQ29X_s3FxOsU+CGV_O63ES_4zSLZcg@mail.gmail.com>
References: <1467932579-14320-1-git-send-email-isubramanian@apm.com>
 <1467932579-14320-10-git-send-email-isubramanian@apm.com>
 <CAOesGMiF0PQocy2jj9Fpz_K-dYRtJDnd789DOCLz35y5g+KVzw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
 Andrew Lunn <andrew@lunn.ch>, Network Development <netdev@vger.kernel.org>,
 patches <patches@apm.com>, Russell King <linux@armlinux.org.uk>,
 Iyappan Subramanian <isubramanian@apm.com>,
 Matthias Brugger <matthias.bgg@gmail.com>, David Miller <davem@davemloft.net>,
 "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>
To: Olof Johansson <olof@lixom.net>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <CAOesGMiF0PQocy2jj9Fpz_K-dYRtJDnd789DOCLz35y5g+KVzw@mail.gmail.com>
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

On Mon, Aug 1, 2016 at 2:13 PM, Olof Johansson <olof@lixom.net> wrote:
>
> Hi,
>
> I came across this now when looking at merge conflicts when preparing
> this. I wish I had seen it sooner.
>
> On Thu, Jul 7, 2016 at 4:02 PM, Iyappan Subramanian
> <isubramanian@apm.com> wrote:
> > Added mdio node for mdio driver.  Also added phy-handle
> > reference to the ethernet nodes.
> >
> > Removed unused mdio subnode within storm menet ethernet node.
> > Removed unused clock node from storm sgenet1.
> >
> > Signed-off-by: Iyappan Subramanian <isubramanian@apm.com>
> > Tested-by: Fushen Chen <fchen@apm.com>
> > Tested-by: Toan Le <toanle@apm.com>
> > Tested-by: Matthias Brugger <mbrugger@suse.com>
> > ---
> >  arch/arm64/boot/dts/apm/apm-mustang.dts | 12 +++++++++++
> >  arch/arm64/boot/dts/apm/apm-storm.dtsi  | 36 ++++++++++++---------------------
> >  2 files changed, 25 insertions(+), 23 deletions(-)
> >
> > diff --git a/arch/arm64/boot/dts/apm/apm-mustang.dts b/arch/arm64/boot/dts/apm/apm-mustang.dts
> > index 44db32e..b7fb5d9 100644
> > --- a/arch/arm64/boot/dts/apm/apm-mustang.dts
> > +++ b/arch/arm64/boot/dts/apm/apm-mustang.dts
> > @@ -79,3 +79,15 @@
> >  &mmc0 {
> >         status = "ok";
> >  };
> > +
> > +&mdio {
> > +       menet0phy: phy@3 {
> > +               reg = <0x3>;
> > +       };
> > +       sgenet0phy: phy@4 {
> > +               reg = <0x4>;
> > +       };
> > +       sgenet1phy: phy@5 {
> > +               reg = <0x5>;
> > +       };
> > +};
> > diff --git a/arch/arm64/boot/dts/apm/apm-storm.dtsi b/arch/arm64/boot/dts/apm/apm-storm.dtsi
> > index 5147d76..a415b3a 100644
> > --- a/arch/arm64/boot/dts/apm/apm-storm.dtsi
> > +++ b/arch/arm64/boot/dts/apm/apm-storm.dtsi
> > @@ -237,20 +237,11 @@
> >                                 clocks = <&socplldiv2 0>;
> >                                 reg = <0x0 0x1f21c000 0x0 0x1000>;
> >                                 reg-names = "csr-reg";
> > -                               csr-mask = <0x3>;
> > +                               csr-mask = <0xa>;
> > +                               enable-mask = <0xf>;
> >                                 clock-output-names = "sge0clk";
> >                         };
> >
> > -                       sge1clk: sge1clk@1f21c000 {
> > -                               compatible = "apm,xgene-device-clock";
> > -                               #clock-cells = <1>;
> > -                               clocks = <&socplldiv2 0>;
> > -                               reg = <0x0 0x1f21c000 0x0 0x1000>;
> > -                               reg-names = "csr-reg";
> > -                               csr-mask = <0xc>;
> > -                               clock-output-names = "sge1clk";
> > -                       };
> > -
> >                         xge0clk: xge0clk@1f61c000 {
> >                                 compatible = "apm,xgene-device-clock";
> >                                 #clock-cells = <1>;
> > @@ -921,6 +912,14 @@
> >                         clocks = <&rtcclk 0>;
> >                 };
> >
> > +               mdio: mdio@0x17020000 {
> > +                       compatible = "apm,xgene-mdio-rgmii";
> > +                       #address-cells = <1>;
> > +                       #size-cells = <0>;
> > +                       reg = <0x0 0x17020000 0x0 0xd100>;
> > +                       clocks = <&menetclk 0>;
> > +               };
> > +
> >                 menet: ethernet@17020000 {
>
>
> This new mmio node has the same unit address, and claims the same
> register window as the ethernet controller.
> That's doesn't seem correct?
Hi Olof,

Unfortunately, Iyappan is on vacation. He will respond as soon as he gets back.

Regards,
Duc Dang.
>
>
> -Olof
