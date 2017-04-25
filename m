From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH 2/2] ARM: dts: Add the ethernet and ethernet PHY to the
 cygnus core DT.
Date: Tue, 25 Apr 2017 12:40:08 +0300
Message-ID: <f870339f-2fa1-411d-5ce8-adbe8802d8a8@cogentembedded.com>
References: <20170424215022.30382-1-eric@anholt.net>
 <20170424215022.30382-3-eric@anholt.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org,
        bcm-kernel-feedback-list@broadcom.com, Ray Jui <rjui@broadcom.com>,
        Scott Branden <sbranden@broadcom.com>,
        Jon Mason <jonmason@broadcom.com>
To: Eric Anholt <eric@anholt.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        Andrew Lunn <andrew@lunn.ch>, netdev@vger.kernel.org,
        Rob Herring <robh+dt@kernel.org>,
        Mark Rutland <mark.rutland@arm.com>, devicetree@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f45.google.com ([209.85.215.45]:34564 "EHLO
        mail-lf0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1177307AbdDYJkL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 25 Apr 2017 05:40:11 -0400
Received: by mail-lf0-f45.google.com with SMTP id t144so87615529lff.1
        for <netdev@vger.kernel.org>; Tue, 25 Apr 2017 02:40:11 -0700 (PDT)
In-Reply-To: <20170424215022.30382-3-eric@anholt.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 4/25/2017 12:50 AM, Eric Anholt wrote:

> Cygnus has a single amac controller connected to the B53 switch with 2
> PHYs.  On the BCM911360_EP platform, those two PHYs are connected to
> the external ethernet jacks.

    My spell checker trips on "amac" and "ethernet" -- perhaps they need 
capitalization?

> Signed-off-by: Eric Anholt <eric@anholt.net>
> ---
>  arch/arm/boot/dts/bcm-cygnus.dtsi      | 60 ++++++++++++++++++++++++++++++++++
>  arch/arm/boot/dts/bcm911360_entphn.dts |  8 +++++
>  2 files changed, 68 insertions(+)
>
> diff --git a/arch/arm/boot/dts/bcm-cygnus.dtsi b/arch/arm/boot/dts/bcm-cygnus.dtsi
> index 009f1346b817..318899df9972 100644
> --- a/arch/arm/boot/dts/bcm-cygnus.dtsi
> +++ b/arch/arm/boot/dts/bcm-cygnus.dtsi
> @@ -142,6 +142,56 @@
>  			interrupts = <0>;
>  		};
>
> +		mdio: mdio@18002000 {
> +			compatible = "brcm,iproc-mdio";
> +			reg = <0x18002000 0x8>;
> +			#size-cells = <1>;
> +			#address-cells = <0>;
> +
> +			gphy0: eth-gphy@0 {

    The node anmes must be generic, the DT spec has standardized 
"ethernet-phy" name for this case.

> +				reg = <0>;
> +				max-speed = <1000>;
> +			};
> +
> +			gphy1: eth-gphy@1 {
> +				reg = <1>;
> +				max-speed = <1000>;
> +			};
> +		};
[...]
> @@ -295,6 +345,16 @@
>  			status = "disabled";
>  		};
>
> +		eth0: enet@18042000 {
> +			compatible = "brcm,amac";
> +			reg = <0x18042000 0x1000>,
> +			      <0x18110000 0x1000>;
> +			reg-names = "amac_base", "idm_base";

    I don't think "_base" suffixes are necessary here.

[...]

MBR, Sergei
