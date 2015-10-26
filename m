From: =?iso-8859-1?Q?M=E5ns_Rullg=E5rd?= <mans@mansr.com>
Subject: Re: [PATCH v3 1/2] devicetree: add binding for Aurora VLSI NB8800 Ethernet controller
Date: Mon, 26 Oct 2015 21:40:53 +0000
Message-ID: <yw1xd1w1e2ai.fsf@unicorn.mansr.com>
References: <1445895295-16778-1-git-send-email-mans@mansr.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Pawel Moll <pawel.moll@arm.com>,
	Mark Rutland <mark.rutland@arm.com>,
	Ian Campbell <ijc+devicetree@hellion.org.uk>,
	Kumar Gala <galak@codeaurora.org>, devicetree@vger.kernel.org,
	linux-kernel@vger.kernel.org, slash.tmp@free.fr,
	netdev@vger.kernel.org
To: Rob Herring <robh+dt@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1445895295-16778-1-git-send-email-mans@mansr.com> (Mans
	Rullgard's message of "Mon, 26 Oct 2015 21:34:54 +0000")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46orgot to CC netdev.

Mans Rullgard <mans@mansr.com> writes:

> This adds a binding for the Aurora VLSI NB8800 Ethernet controller
> using the "aurora,nb8800" compatible string.  When used in Sigma
> Designs chips a few additional features are available.  These variant=
s
> are indicated by a "sigma,<chip>-ethernet" compatible string.
>
> Signed-off-by: Mans Rullgard <mans@mansr.com>
> ---
> Changes:
> - added phy child node
> ---
>  .../devicetree/bindings/net/aurora,nb8800.txt      | 37 ++++++++++++=
++++++++++
>  1 file changed, 37 insertions(+)
>  create mode 100644 Documentation/devicetree/bindings/net/aurora,nb88=
00.txt
>
> diff --git a/Documentation/devicetree/bindings/net/aurora,nb8800.txt =
b/Documentation/devicetree/bindings/net/aurora,nb8800.txt
> new file mode 100644
> index 0000000..df12ff1
> --- /dev/null
> +++ b/Documentation/devicetree/bindings/net/aurora,nb8800.txt
> @@ -0,0 +1,37 @@
> +* Aurora VLSI AU-NB8800 Ethernet controller
> +
> +Required properties:
> +- compatible: Should be "sigma,<chip>-ethernet", "aurora,nb8800"
> +- reg: Should be MMIO address space of the device
> +- interrupts: Should contain the interrupt specifier for the device
> +- interrupt-parent: Should be a phandle for the interrupt controller
> +- clocks: Should be a phandle for the clock for the device
> +- #address-cells: Should be <1>
> +- #size-cells: Should be <0>
> +
> +Common properties described in ethernet.txt:
> +- local-mac-address
> +- mac-address
> +- phy-handle
> +- phy-mode
> +
> +The attached PHY should be specified in a child node as per phy.txt.
> +
> +Example:
> +
> +ethernet@26000 {
> +	compatible =3D "sigma,smp8642-ethernet", "aurora,nb8800";
> +	reg =3D <0x26000 0x800>;
> +	interrupts =3D <38>;
> +	clocks =3D <&sys_clk>;
> +	max-speed =3D <1000>;
> +	phy-connection-type =3D "rgmii";
> +	phy-handle =3D <&eth0_phy>;
> +	#address-cells =3D <1>;
> +	#size-cells =3D <0>;
> +
> +	eth0_phy: ethernet-phy@1 {
> +		compatible =3D "ethernet-phy-ieee802.3-c22";
> +		reg =3D <1>;
> +	};
> +};
> --=20
> 2.6.2
>

--=20
M=E5ns Rullg=E5rd
mans@mansr.com
