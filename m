From: Greg KH <gregkh@linuxfoundation.org>
Subject: Re: [PATCH v7 3/8] thunderbolt: Kconfig for Thunderbolt Networking
Date: Tue, 27 Sep 2016 16:00:44 +0200
Message-ID: <20160927140044.GA21133@kroah.com>
References: <1474983821-2313-1-git-send-email-amir.jer.levy@intel.com>
 <1474983821-2313-4-git-send-email-amir.jer.levy@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: andreas.noever@gmail.com, bhelgaas@google.com, corbet@lwn.net,
        linux-kernel@vger.kernel.org, linux-pci@vger.kernel.org,
        netdev@vger.kernel.org, linux-doc@vger.kernel.org,
        mario_limonciello@dell.com, thunderbolt-linux@intel.com,
        mika.westerberg@intel.com, tomas.winkler@intel.com,
        xiong.y.zhang@intel.com
To: Amir Levy <amir.jer.levy@intel.com>
Return-path: <linux-doc-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1474983821-2313-4-git-send-email-amir.jer.levy@intel.com>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Sep 27, 2016 at 04:43:36PM +0300, Amir Levy wrote:
> Update to the Kconfig Thunderbolt description to add
> Thunderbolt networking as an option.
> The menu item "Thunderbolt support" now offers:
> "Apple Hardware Support" (existing)
>         and/or
> "Thunderbolt Networking" (new)
> 
> You can choose the driver for your platform or build both drivers -
> each driver will detect if it can run on the specific platform.
> If the Thunderbolt Networking option is chosen, Thunderbolt Networking
> will be enabled between Linux non-Apple systems, macOS and
> Windows based systems.
> Thunderbolt Networking will not affect any other Thunderbolt feature that
> was previous available to Linux users on either Apple or
> non-Apple platforms.
> 
> Signed-off-by: Amir Levy <amir.jer.levy@intel.com>
> ---
>  drivers/thunderbolt/Kconfig  | 27 +++++++++++++++++++++++----
>  drivers/thunderbolt/Makefile |  2 +-
>  2 files changed, 24 insertions(+), 5 deletions(-)
> 
> diff --git a/drivers/thunderbolt/Kconfig b/drivers/thunderbolt/Kconfig
> index c121acc..376e5bb 100644
> --- a/drivers/thunderbolt/Kconfig
> +++ b/drivers/thunderbolt/Kconfig
> @@ -1,13 +1,32 @@
> -menuconfig THUNDERBOLT
> -	tristate "Thunderbolt support for Apple devices"
> +config THUNDERBOLT
> +	tristate "Thunderbolt support"
>  	depends on PCI
>  	select CRC32
>  	help
> -	  Cactus Ridge Thunderbolt Controller driver
> +	  Thunderbolt Controller driver
> +
> +if THUNDERBOLT
> +
> +config THUNDERBOLT_APPLE
> +	tristate "Apple hardware support"
> +	help
>  	  This driver is required if you want to hotplug Thunderbolt devices on
>  	  Apple hardware.
>  
>  	  Device chaining is currently not supported.
>  
> -	  To compile this driver a module, choose M here. The module will be
> +	  To compile this driver as a module, choose M here. The module will be
>  	  called thunderbolt.
> +
> +config THUNDERBOLT_ICM

You are adding a config option here that is not used in the tree yet.
Please wait until you need the option to actually add it :)

You might just want to do the APPLE stuff here, that way you can drop in
the networking stuff in a simple patch at the end of this series.

thanks,

greg k-h
