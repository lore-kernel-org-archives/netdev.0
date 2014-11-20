From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH 00/10] net: phy: add device-type abstraction
Date: Thu, 20 Nov 2014 08:18:47 -0800
Message-ID: <546E1467.9090607@gmail.com>
References: <1416398363-32306-1-git-send-email-johan@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Bruno Thomsen <bth@kamstrup.dk>,
	Sascha Hauer <s.hauer@pengutronix.de>,
	Mark Rutland <mark.rutland@arm.com>
To: Johan Hovold <johan@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1416398363-32306-1-git-send-email-johan@kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 11/19/2014 03:59 AM, Johan Hovold wrote:
> This series adds device and device-type abstractions to the micrel
> driver, and enables support for RMII-reference clock selection for
> KSZ8081 and KSZ8091 devices.
> 
> While adding support for more features for the Micrel PHYs mentioned
> above, it became apparent that the configuration space is much too large
> and that adding type-specific callbacks will simply not scale. Instead I
> added a driver_data field to struct phy_device, which can be used to
> store static device type data that can be parsed and acted on in
> generic driver callbacks. This allows a lot of duplicated code to be
> removed, and should make it much easier to add new features or deal with
> device-type quirks in the future.
> 
> The series has been tested on a dual KSZ8081 setup. Further testing on
> other Micrel PHYs would be much appreciated.
> 
> The recent commit a95a18afe4c8 ("phy/micrel: KSZ8031RNL RMII clock
> reconfiguration bug") currently prevents KSZ8031 PHYs from using the
> generic config-init. Bruno, who is the author of that patch, has agreed
> to test this series and some follow-up diagnostic patches to determine
> how best to incorporate these devices as well. I intend to send a
> follow-up patch that removes the custom 8031 config-init and documents
> this quirk, but the current series can be applied meanwhile.
> 
> These patches are against net-next which contains some already merged
> prerequisite patches to the driver.

LGTM, thanks Johan!

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>

> 
> Johan
> 
> 
> Johan Hovold (10):
>   net: phy: add static data field to struct phy_driver
>   net: phy: micrel: add device-type abstraction
>   net: phy: micrel: parse of nodes at probe
>   net: phy: micrel: add has-broadcast-disable flag to type data
>   net: phy: micrel: add generic clock-mode-select support
>   net: phy: micrel: add support for clock-mode select to KSZ8081/KSZ8091
>   dt/bindings: reformat micrel eth-phy documentation
>   dt/bindings: add clock-select function property to micrel phy binding
>   net: phy: micrel: refactor interrupt config
>   net: phy: micrel: add copyright entry
> 
>  Documentation/devicetree/bindings/net/micrel.txt |  37 ++--
>  drivers/net/phy/micrel.c                         | 262 ++++++++++++++---------
>  include/linux/micrel_phy.h                       |   1 -
>  include/linux/phy.h                              |   2 +
>  4 files changed, 184 insertions(+), 118 deletions(-)
> 
