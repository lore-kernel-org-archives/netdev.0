From: Jean-Francois Moine <moinejf@free.fr>
Subject: Re: [PATCH v4 04/10] ARM: dts: sun8i-h3: Add dt node for the syscon
 control module
Date: Mon, 10 Oct 2016 14:50:21 +0200
Message-ID: <20161010145021.00586f772e3398833217796a@free.fr>
References: <1475828757-926-1-git-send-email-clabbe.montjoie@gmail.com>
 <1475828757-926-5-git-send-email-clabbe.montjoie@gmail.com>
 <20161010123151.GI3462@lukather>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: mark.rutland@arm.com, andrew@lunn.ch, f.fainelli@gmail.com,
 devicetree@vger.kernel.org, netdev@vger.kernel.org, linux@armlinux.org.uk,
 linux-kernel@vger.kernel.org, wens@csie.org, robh+dt@kernel.org,
 Corentin Labbe <clabbe.montjoie@gmail.com>, davem@davemloft.net,
 linux-arm-kernel@lists.infradead.org
To: Maxime Ripard <maxime.ripard@free-electrons.com>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <20161010123151.GI3462@lukather>
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

On Mon, 10 Oct 2016 14:31:51 +0200
Maxime Ripard <maxime.ripard@free-electrons.com> wrote:

> Hi,
> =

> On Fri, Oct 07, 2016 at 10:25:51AM +0200, Corentin Labbe wrote:
> > This patch add the dt node for the syscon register present on the
> > Allwinner H3.
> > =

> > Only two register are present in this syscon and the only one useful is
> > the one dedicated to EMAC clock.
> > =

> > Signed-off-by: Corentin Labbe <clabbe.montjoie@gmail.com>
> > ---
> >  arch/arm/boot/dts/sun8i-h3.dtsi | 5 +++++
> >  1 file changed, 5 insertions(+)
> > =

> > diff --git a/arch/arm/boot/dts/sun8i-h3.dtsi b/arch/arm/boot/dts/sun8i-=
h3.dtsi
> > index 8a95e36..1101d2f 100644
> > --- a/arch/arm/boot/dts/sun8i-h3.dtsi
> > +++ b/arch/arm/boot/dts/sun8i-h3.dtsi
> > @@ -140,6 +140,11 @@
> >  		#size-cells =3D <1>;
> >  		ranges;
> >  =

> > +		syscon: syscon@01c00000 {
> > +			compatible =3D "syscon";
> =

> It would be great to have a more specific compatible here in addition
> to the syscon, like "allwinner,sun8i-h3-system-controller".

The System Control area is just like the PRCM area: it would be simpler
to define the specific registers in the associated drivers.

Here, instead of the syscon node, plus

+		emac: ethernet@1c30000 {
+			compatible =3D "allwinner,sun8i-h3-emac";
+			syscon =3D <&syscon>;
+			reg =3D <0x01c30000 0x104>;
+			interrupts =3D <GIC_SPI 82 IRQ_TYPE_LEVEL_HIGH>;
			...

there would be no 'syscon' node and

+		emac: ethernet@1c30000 {
+			compatible =3D "allwinner,sun8i-h3-emac";
+			syscon =3D <&syscon>;
+			reg =3D	<0x01c30000 0x104>,	/* EMAC */
+				<0x01c00030 4>;		/* system control */
+			interrupts =3D <GIC_SPI 82 IRQ_TYPE_LEVEL_HIGH>;
			...

-- =

Ken ar c'henta=F1	|	      ** Breizh ha Linux atav! **
Jef		|		http://moinejf.free.fr/
