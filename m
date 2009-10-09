From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: Re: [PATCH] [CAIF-RFC 5/8-v2] CAIF Protocol Stack
Date: Fri, 9 Oct 2009 09:43:06 -0700
Message-ID: <20091009094306.4671ef33.randy.dunlap@oracle.com>
References: <1255095571-6501-1-git-send-email-sjur.brandeland@stericsson.com>
	<1255095571-6501-2-git-send-email-sjur.brandeland@stericsson.com>
	<1255095571-6501-3-git-send-email-sjur.brandeland@stericsson.com>
	<1255095571-6501-4-git-send-email-sjur.brandeland@stericsson.com>
	<1255095571-6501-5-git-send-email-sjur.brandeland@stericsson.com>
	<1255095571-6501-6-git-send-email-sjur.brandeland@stericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, stefano.babic@babic.homelinux.org,
	randy.dunlap@oracle.com, kim.xx.lilliestierna@stericsson.com,
	christian.bejram@stericsson.com, daniel.martensson@stericsson.com
To: sjur.brandeland@stericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from rcsinet11.oracle.com ([148.87.113.123]:16706 "EHLO
	rgminet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753861AbZJIQpk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Oct 2009 12:45:40 -0400
In-Reply-To: <1255095571-6501-6-git-send-email-sjur.brandeland@stericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 09 Oct 2009 15:39:28 +0200 sjur.brandeland@stericsson.com wrote:

> From: Sjur Braendeland <sjur.brandeland@stericsson.com>
> 
> Change-Id: I205c5b3baf1542e1593637ce896d8684870415be
> Signed-off-by: Sjur Braendeland <sjur.brandeland@stericsson.com>
> ---
>  net/caif/Kconfig            |   61 ++
>  net/caif/Makefile           |   56 ++
>  net/caif/caif_chnlif.c      |  219 +++++++
>  net/caif/caif_chr.c         |  374 ++++++++++++
>  net/caif/caif_config_util.c |  167 ++++++
>  net/caif/chnl_chr.c         | 1393 +++++++++++++++++++++++++++++++++++++++++++
>  net/caif/chnl_net.c         |  492 +++++++++++++++
>  7 files changed, 2762 insertions(+), 0 deletions(-)
>  create mode 100644 net/caif/Kconfig
>  create mode 100644 net/caif/Makefile
>  create mode 100644 net/caif/caif_chnlif.c
>  create mode 100644 net/caif/caif_chr.c
>  create mode 100644 net/caif/caif_config_util.c
>  create mode 100644 net/caif/chnl_chr.c
>  create mode 100644 net/caif/chnl_net.c
> 
> diff --git a/net/caif/Kconfig b/net/caif/Kconfig
> new file mode 100644
> index 0000000..7fb9e9c
> --- /dev/null
> +++ b/net/caif/Kconfig
> @@ -0,0 +1,61 @@
> +#
> +# CAIF net configurations
> +#
> +
> +#menu "Caif Support"
> +comment "CAIF Support"
> +
> +menuconfig CAIF
> +	tristate "Enable Caif support"
> +	default n
> +	---help---
> +	Say Y here if you need to use a phone modem that uses CAIF as transport

	end above with period ('.').

> +	You will also need to say yes to any caif physical devices that your platform
> +	supports.
> +	This can be either built-in or as a loadable module, if you select to build it as module

s/,/;/

> +	the other CAIF also needs to built as modules

	the other CAIF {options or drivers or some other word here} also need  ... modules.
	(end with period)


> +	See Documentation/CAIF for a further explanation on how to use and configure.
> +
> +if CAIF
> +
> +config CAIF_CHARDEV
> +	tristate "CAIF character device"
> +	default CAIF
> +	---help---
> +	Say Y if you will be using the CAIF AT type character devices.
> +	This can be either built-in or as a loadable module,
> +	If you select to build it as a built in then the main caif device must also be a builtin.
> +	If unsure say Y.
> +
> +config CAIF_NETDEV
> +	tristate "CAIF Network device"
> +	default CAIF
> +	---help---
> +	Say Y if you will be using the CAIF based network device.
> +	This can be either built-in or as a loadable module,
> +	If you select to build it as a built in then the main caif device must also be a builtin.
> +	If unsure say Y.
> +
> +
> +config  CAIF_USE_PLAIN
> +	bool  "Use plain buffers instead of SKB in caif"
> +	default n
> +	---help---
> +	Use plain buffer to transport data,

	s/,/./

> +	Select what type of internal buffering CAIF should use,
> +	skb or plain.
> +	If unsure say N hre.
> +
> +config  CAIF_DEBUG
> +	bool "Enable Debug"
> +	default n
> +	--- help ---
> +	Enable the inclusion of debug code in the caif stack,
> +	be aware that doing this will impact performance.
> +	If unsure say N here.
> +
> +# Include physical drivers
> +# source "drivers/net/caif/Kconfig"

Drop the above line.

> +source "drivers/net/caif/Kconfig"
> +endif
> +#endmenu


---
~Randy
