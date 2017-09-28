From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next RFC 2/9] net: dsa: mv88e6xxx: expose switch time
 as a PTP hardware clock
Date: Thu, 28 Sep 2017 18:56:43 +0200
Message-ID: <20170928165643.GB14940@lunn.ch>
References: <1506612341-18061-1-git-send-email-brandon.streiff@ni.com>
 <1506612341-18061-3-git-send-email-brandon.streiff@ni.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        Richard Cochran <richardcochran@gmail.com>,
        Erik Hons <erik.hons@ni.com>
To: Brandon Streiff <brandon.streiff@ni.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1506612341-18061-3-git-send-email-brandon.streiff@ni.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Sep 28, 2017 at 10:25:34AM -0500, Brandon Streiff wrote:
> This patch adds basic support for exposing the 32-bit timestamp counter
> inside the mv88e6xxx switch code as a ptp_clock.
> 
> Signed-off-by: Brandon Streiff <brandon.streiff@ni.com>
> ---
>  drivers/net/dsa/mv88e6xxx/Kconfig  |  10 +++
>  drivers/net/dsa/mv88e6xxx/Makefile |   1 +
>  drivers/net/dsa/mv88e6xxx/chip.c   |  20 +++++
>  drivers/net/dsa/mv88e6xxx/chip.h   |  16 ++++
>  drivers/net/dsa/mv88e6xxx/ptp.c    | 180 +++++++++++++++++++++++++++++++++++++
>  drivers/net/dsa/mv88e6xxx/ptp.h    |  83 +++++++++++++++++
>  6 files changed, 310 insertions(+)
>  create mode 100644 drivers/net/dsa/mv88e6xxx/ptp.c
>  create mode 100644 drivers/net/dsa/mv88e6xxx/ptp.h
> 
> diff --git a/drivers/net/dsa/mv88e6xxx/Kconfig b/drivers/net/dsa/mv88e6xxx/Kconfig
> index 1aaa7a9..ae9e7f7 100644
> --- a/drivers/net/dsa/mv88e6xxx/Kconfig
> +++ b/drivers/net/dsa/mv88e6xxx/Kconfig
> @@ -18,3 +18,13 @@ config NET_DSA_MV88E6XXX_GLOBAL2
>  
>  	  It is required on most chips. If the chip you compile the support for
>  	  doesn't have such registers set, say N here. In doubt, say Y.
> +
> +config NET_DSA_MV88E6XXX_PTP
> +	bool "PTP support for Marvell 88E6xxx"
> +	default n
> +	depends on NET_DSA_MV88E6XXX_GLOBAL2
> +	imply NETWORK_PHY_TIMESTAMPING

Hi Brandon

Cool to see this code.

One probably dumb question so far..

It is the MAC which is doing the time stamping, not they PHY?
So why NETWORK_PHY_TIMESTAMPING?

   Andrew
