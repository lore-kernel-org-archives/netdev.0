From: David Daney <ddaney@caviumnetworks.com>
Subject: Re: [PATCH 1/3] net: mdio-octeon: Modify driver to work on both
 ThunderX and Octeon
Date: Tue, 28 Jul 2015 07:07:24 -0700
Message-ID: <55B78C9C.6080006@caviumnetworks.com>
References: <1438049683-10630-1-git-send-email-mohun106@gmail.com>
 <1438049683-10630-2-git-send-email-mohun106@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Radha Mohan Chintakuntla <rchintakuntla@cavium.com>,
	Sunil Goutham <sgoutham@cavium.com>,
	David Daney <david.daney@cavium.com>
To: <mohun106@gmail.com>, <f.fainelli@gmail.com>,
	<netdev@vger.kernel.org>, <linux-arm-kernel@lists.infradead.org>,
	<linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1438049683-10630-2-git-send-email-mohun106@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 07/27/2015 07:14 PM, mohun106@gmail.com wrote:
> From: Radha Mohan Chintakuntla <rchintakuntla@cavium.com>
>
> This patch modifies the mdio-octeon driver to work on both ThunderX and
> Octeon SoCs from Cavium Inc.
>
> Signed-off-by: Sunil Goutham <sgoutham@cavium.com>
> Signed-off-by: Radha Mohan Chintakuntla <rchintakuntla@cavium.com>
> Signed-off-by: David Daney <david.daney@cavium.com>
> ---
>   drivers/net/phy/Kconfig       |    9 ++-
>   drivers/net/phy/mdio-octeon.c |  122 +++++++++++++++++++++++++++++++++++-----
>   2 files changed, 111 insertions(+), 20 deletions(-)
>
> diff --git a/drivers/net/phy/Kconfig b/drivers/net/phy/Kconfig
> index cf18940..0d6af19 100644
> --- a/drivers/net/phy/Kconfig
> +++ b/drivers/net/phy/Kconfig
> @@ -145,13 +145,14 @@ config MDIO_GPIO
>   	  will be called mdio-gpio.
>
>   config MDIO_OCTEON
> -	tristate "Support for MDIO buses on Octeon SOCs"
> -	depends on CAVIUM_OCTEON_SOC
> +	tristate "Support for MDIO buses on Octeon and ThunderX SOCs"
> +	depends on 64BIT
>   	default y

If it now depends only on 64BIT, we should probably remove the 
"default".  People building for x86 are not interested in this driver.


[...]
>
> +#ifdef __BIG_ENDIAN_BITFIELD
> +#define OCT_MDIO_BITFIELD_FIELD(field, more)	\
> +	field;					\
> +	more
> +
> +#else
> +#define OCT_MDIO_BITFIELD_FIELD(field, more)	\
> +	more					\
> +	field;
> +
> +#endif
> +
> +union cvmx_smix_clk {
> +	uint64_t u64;

Perhaps: s/uint64_t/u64/

There are several of these.


> +	struct cvmx_smix_clk_s {
> +	  OCT_MDIO_BITFIELD_FIELD(u64 reserved_25_63:39,
> +	  OCT_MDIO_BITFIELD_FIELD(u64 mode:1,
> +	  OCT_MDIO_BITFIELD_FIELD(u64 reserved_21_23:3,
> +	  OCT_MDIO_BITFIELD_FIELD(u64 sample_hi:5,
> +	  OCT_MDIO_BITFIELD_FIELD(u64 sample_mode:1,
> +	  OCT_MDIO_BITFIELD_FIELD(u64 reserved_14_14:1,
> +	  OCT_MDIO_BITFIELD_FIELD(u64 clk_idle:1,
> +	  OCT_MDIO_BITFIELD_FIELD(u64 preamble:1,
> +	  OCT_MDIO_BITFIELD_FIELD(u64 sample:4,
> +	  OCT_MDIO_BITFIELD_FIELD(u64 phase:8,
> +	  ;))))))))))
> +	} s;
> +};
> +
[...]
