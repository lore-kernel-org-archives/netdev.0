From: Kumar Gala <galak@kernel.crashing.org>
Subject: Re: [PATCH 3/3] ptp: Added a clock that uses the eTSEC found on the MPC85xx.
Date: Sat, 1 May 2010 11:36:12 -0500
Message-ID: <FFD6BE31-AF2B-4D44-9751-61DB06327DBD@kernel.crashing.org>
References: <20100429092005.GA6727@riccoc20.at.omicron.at>
Mime-Version: 1.0 (Apple Message framework v1078)
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: Netdev <netdev@vger.kernel.org>,
	linuxppc-dev <linuxppc-dev@lists.ozlabs.org>,
	devicetree-discuss <devicetree-discuss@ozlabs.org>
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:60406 "EHLO gate.crashing.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754161Ab0EAQgX convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 1 May 2010 12:36:23 -0400
In-Reply-To: <20100429092005.GA6727@riccoc20.at.omicron.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Apr 29, 2010, at 4:20 AM, Richard Cochran wrote:

> The eTSEC includes a PTP clock with quite a few features. This patch adds
> support for the basic clock adjustment functions.
> 
> Signed-off-by: Richard Cochran <richard.cochran@omicron.at>
> ---
> arch/powerpc/boot/dts/mpc8313erdb.dts |   14 ++
> arch/powerpc/boot/dts/p2020ds.dts     |   13 ++
> arch/powerpc/boot/dts/p2020rdb.dts    |   14 ++
> drivers/net/Makefile                  |    1 +
> drivers/net/gianfar_ptp.c             |  308 +++++++++++++++++++++++++++++++++
> drivers/net/gianfar_ptp_reg.h         |  107 ++++++++++++
> drivers/ptp/Kconfig                   |   13 ++
> 7 files changed, 470 insertions(+), 0 deletions(-)
> create mode 100644 drivers/net/gianfar_ptp.c
> create mode 100644 drivers/net/gianfar_ptp_reg.h
> 
> diff --git a/arch/powerpc/boot/dts/mpc8313erdb.dts b/arch/powerpc/boot/dts/mpc8313erdb.dts
> index 183f2aa..b760aee 100644
> --- a/arch/powerpc/boot/dts/mpc8313erdb.dts
> +++ b/arch/powerpc/boot/dts/mpc8313erdb.dts
> @@ -208,6 +208,20 @@
> 			sleep = <&pmc 0x00300000>;
> 		};
> 
> +		ptp_clock@24E00 {
> +			device_type = "ptp_clock";
> +			model = "eTSEC";
> +			reg = <0x24E00 0xB0>;
> +			interrupts = <0x0C 2 0x0D 2>;
> +			interrupt-parent = < &ipic >;
> +			tclk_period = <10>;
> +			tmr_prsc    = <100>;
> +			tmr_add     = <0x999999A4>;
> +			cksel       = <0x1>;
> +			tmr_fiper1  = <0x3B9AC9F6>;
> +			tmr_fiper2  = <0x00018696>;
> +		};
> +
> 		enet0: ethernet@24000 {
> 			#address-cells = <1>;
> 			#size-cells = <1>;

Is there a binding document that describes this node you are adding?

- k