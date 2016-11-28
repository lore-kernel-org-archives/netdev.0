From: Neil Armstrong <narmstrong-rdvid1DuHRBWk0Htik3J/w@public.gmane.org>
Subject: Re: [PATCH net-next v3 0/4] Fix OdroidC2 Gigabit Tx link issue
Date: Mon, 28 Nov 2016 14:42:36 +0100
Message-ID: <47182829-240d-e4d3-420e-7ee9f08a3dcf@baylibre.com>
References: <1480326409-25419-1-git-send-email-jbrunet@baylibre.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Carlo Caione <carlo-KA+7E9HrN00dnm+yROfE0A@public.gmane.org>,
        Kevin Hilman <khilman-rdvid1DuHRBWk0Htik3J/w@public.gmane.org>,
        Giuseppe Cavallaro <peppe.cavallaro-qxv4g6HH51o@public.gmane.org>,
        Alexandre TORGUE <alexandre.torgue-qxv4g6HH51o@public.gmane.org>,
        Martin Blumenstingl <martin.blumenstingl-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org>,
        Andre Roth <neolynx-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>,
        linux-amlogic-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
        linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Jerome Brunet <jbrunet-rdvid1DuHRBWk0Htik3J/w@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1480326409-25419-1-git-send-email-jbrunet-rdvid1DuHRBWk0Htik3J/w@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 11/28/2016 10:46 AM, Jerome Brunet wrote:
> This patchset fixes an issue with the OdroidC2 board (DWMAC + RTL8211F).
> The platform seems to enter LPI on the Rx path too often while performing
> relatively high TX transfer. This eventually break the link (both Tx and
> Rx), and require to bring the interface down and up again to get the Rx
> path working again.
> 
> The root cause of this issue is not fully understood yet but disabling EEE
> advertisement on the PHY prevent this feature to be negotiated.
> With this change, the link is stable and reliable, with the expected
> throughput performance.
> 
> The patchset adds options in the generic phy driver to disable EEE
> advertisement, through device tree. The way it is done is very similar
> to the handling of the max-speed property.
> 
> Changes since V2: [2]
>  - Rename "eee-advert-disable" to "eee-broken-modes" to make the intended
>    purpose of this option clear (flag broken configuration, not a
>    configuration option)
>  - Add DT bindings constants so the DT configuration is more user friendly
>  - Submit to net-next instead of net.
> 
> Changes since V1: [1]
>  - Disable the advertisement of EEE in the generic code instead of the
>    realtek driver.
> 
> [1] : http://lkml.kernel.org/r/1479220154-25851-1-git-send-email-jbrunet-rdvid1DuHRBWk0Htik3J/w@public.gmane.org
> [2] : http://lkml.kernel.org/r/1479742524-30222-1-git-send-email-jbrunet-rdvid1DuHRBWk0Htik3J/w@public.gmane.org
> 
> 
> Jerome Brunet (4):
>   net: phy: add an option to disable EEE advertisement
>   dt-bindings: net: add EEE capability constants
>   dt: bindings: add ethernet phy eee-broken-modes option documentation
>   ARM64: dts: meson: odroidc2: disable advertisement EEE for GbE.
> 
>  Documentation/devicetree/bindings/net/phy.txt      |  2 +
>  .../arm64/boot/dts/amlogic/meson-gxbb-odroidc2.dts | 16 +++++
>  drivers/net/phy/phy.c                              |  3 +
>  drivers/net/phy/phy_device.c                       | 80 +++++++++++++++++++---
>  include/dt-bindings/net/mdio.h                     | 19 +++++
>  include/linux/phy.h                                |  3 +
>  6 files changed, 114 insertions(+), 9 deletions(-)
>  create mode 100644 include/dt-bindings/net/mdio.h
> 

Tested using Nexbox A1 (S912) and Amlogic P230 (S905D) devices (DWMAC + RTL8211F).

Tested-by: Neil Armstrong <narmstrong-rdvid1DuHRBWk0Htik3J/w@public.gmane.org>
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
