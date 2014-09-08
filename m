From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH 05/13] ARM: dts: DRA7: Add DCAN nodes
Date: Mon, 08 Sep 2014 20:40:00 +0400
Message-ID: <540DDBE0.5090004@cogentembedded.com>
References: <1410185442-907-1-git-send-email-rogerq@ti.com> <1410185442-907-6-git-send-email-rogerq@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: tglx@linutronix.de, linux-omap@vger.kernel.org,
	linux-can@vger.kernel.org, netdev@vger.kernel.org,
	mugunthanvnm@ti.com, george.cherian@ti.com, balbi@ti.com,
	nsekhar@ti.com, nm@ti.com
To: Roger Quadros <rogerq@ti.com>, wg@grandegger.com,
	mkl@pengutronix.de, tony@atomide.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f52.google.com ([209.85.215.52]:37892 "EHLO
	mail-la0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754729AbaIHQkD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Sep 2014 12:40:03 -0400
Received: by mail-la0-f52.google.com with SMTP id b8so6284940lan.39
        for <netdev@vger.kernel.org>; Mon, 08 Sep 2014 09:40:01 -0700 (PDT)
In-Reply-To: <1410185442-907-6-git-send-email-rogerq@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 9/8/2014 6:10 PM, Roger Quadros wrote:

> The SoC supports 2 DCAN nodes. Add them.

> Signed-off-by: Roger Quadros <rogerq@ti.com>
> ---
>   arch/arm/boot/dts/dra7.dtsi | 30 ++++++++++++++++++++++++++++++
>   1 file changed, 30 insertions(+)

> diff --git a/arch/arm/boot/dts/dra7.dtsi b/arch/arm/boot/dts/dra7.dts=
i
> index 370009e..4ce1a4f 100644
> --- a/arch/arm/boot/dts/dra7.dtsi
> +++ b/arch/arm/boot/dts/dra7.dtsi
[...]
> @@ -1267,6 +1269,34 @@
>   			ti,irqs-skip =3D <10 133 139 140>;
>   			ti,irqs-safe-map =3D <0>;
>   		};
> +
> +		dcan1: d_can@481cc000 {

    The ePAPR standard has something to say here:

 >>
The name of a node should be somewhat generic, reflecting the function =
of the=20
device and not its precise programming model. If appropriate, the name =
should=20
be one of the following choices:

	=95 can
 >>

> +			compatible =3D "bosch,d_can";
> +			ti,hwmods =3D "dcan1";
> +			reg =3D <0x4ae3c000 0x2000>,
> +			      <0x558 0x4>; /* index to RAMINIT reg within syscon */
> +			raminit-syscon =3D <&dra7_ctrl_core>;
> +			raminit-start-bit =3D <3>;
> +			raminit-done-bit =3D <1>;
> +			raminit-pulse;

    Hm, aren't the above 4 properties vendor specific? If so, they shou=
ld=20
start with a vendor prefix and comma.

> +			interrupts =3D <GIC_SPI 222 IRQ_TYPE_LEVEL_HIGH>;
> +			clocks =3D <&dcan1_sys_clk_mux>;
> +			status =3D "disabled";
> +		};

WBR, Sergei
