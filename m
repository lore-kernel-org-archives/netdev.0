From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: Re: [PATCH 6/8] [RFC] CAIF Protocol Stack
Date: Wed, 23 Sep 2009 21:00:34 -0700
Message-ID: <20090923210034.998558c0.randy.dunlap@oracle.com>
References: <1253727091-10383-1-git-send-email-sjur.brandeland@stericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Kim.xx.Lilliestierna@ericsson.com
To: sjur.brandeland@stericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from rcsinet12.oracle.com ([148.87.113.124]:26259 "EHLO
	rgminet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750710AbZIXEAp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Sep 2009 00:00:45 -0400
In-Reply-To: <1253727091-10383-1-git-send-email-sjur.brandeland@stericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 23 Sep 2009 19:31:31 +0200 sjur.brandeland@stericsson.com wrote:

> From: Kim Lilliestierna <Kim.xx.Lilliestierna@ericsson.com>
> 
> Signed-off-by: sjur.brandeland@stericsson.com
> 
> ---
>  drivers/net/caif/Kconfig      |   64 +++
>  drivers/net/caif/Makefile     |   29 ++
>  drivers/net/caif/chnl_tty.c   |  220 +++++++++++
>  drivers/net/caif/phyif_loop.c |  309 +++++++++++++++
>  drivers/net/caif/phyif_ser.c  |  189 +++++++++
>  drivers/net/caif/phyif_shm.c  |  870 +++++++++++++++++++++++++++++++++++++++++
>  drivers/net/caif/shm.h        |   95 +++++
>  drivers/net/caif/shm_cfgifc.c |   60 +++
>  drivers/net/caif/shm_mbxifc.c |   98 +++++
>  drivers/net/caif/shm_smbx.c   |   81 ++++
>  10 files changed, 2015 insertions(+), 0 deletions(-)
>  create mode 100644 drivers/net/caif/Kconfig
>  create mode 100644 drivers/net/caif/Makefile
>  create mode 100644 drivers/net/caif/chnl_tty.c
>  create mode 100644 drivers/net/caif/phyif_loop.c
>  create mode 100644 drivers/net/caif/phyif_ser.c
>  create mode 100644 drivers/net/caif/phyif_shm.c
>  create mode 100644 drivers/net/caif/shm.h
>  create mode 100644 drivers/net/caif/shm_cfgifc.c
>  create mode 100644 drivers/net/caif/shm_mbxifc.c
>  create mode 100644 drivers/net/caif/shm_smbx.c
> 
> diff --git a/drivers/net/caif/Kconfig b/drivers/net/caif/Kconfig
> new file mode 100644
> index 0000000..3cbe302
> --- /dev/null
> +++ b/drivers/net/caif/Kconfig
> @@ -0,0 +1,64 @@
> +#
> +# CAIF net configurations
> +#
> +
> +if CAIF
> +
> +# Include physical drivers
> +# should be broken out into its own config file
> +# source "drivers/net/caif/Kconfig"
> +
> +# Some options here should be mande platform dependent

                                 made

> +
> +comment "CAIF physical drivers"
> +
> +config CAIF_TTY
> +	tristate "CAIF TTY transport driver "

	no trailing space, please (before the final ")

> +	default CAIF
> +	---help---
> +	The CAIF TTY transport driver
> +	If sou say yes here you will also need to build a users space utility to set the line disicpline on the the

	If you ......                                     userspace [or user space]

	drop final (duplicate) "the" above.

> +	tty, see Documentation/net/caif/examples/linedsc
> +
> +config CAIF_SHM
> +	tristate "CAIF shared memory transport driver"
> +	default n
> +	---help---
> +	The caif low level driver for the shared memory driver

	End sentences with a period ('.').

> +	Be aware that if you enable this you need to also enable a low level shared memory driver

	End above with period.  Begin below with "The".

> +        the default is to include the loopback test driver.
> +
> +config CAIF_LOOPBACK
> +	tristate "CAIF loopback driver test driver"
> +	default CAIF
> +	---help---
> +	Loopback test driver
> +
> +if CAIF_SHM
> +
> +comment "CAIF shared memory low level physical drivers"
> +
> +config CAIF_SHM_LOOPBACK
> +	tristate "Caif shared memory loopback driver"
> +	default CAIF_USE_SHM
> +	---help---
> +	loop back driver that emulates a real shared memory transport
> +	mainly used for debugging.
> +
> +config CAIF_MBXIF
> +	tristate "Caif shared mailbox interface"
> +	default CAIF_SHM
> +	---help---
> +	Generic shared mailbox interface
> +
> +config CAIF_SMBX
> +	tristate "Use Simluated Mail box"
> +	default CAIF_MBXIF
> +	---help---
> +	Answer y if you whant to use a simulated mail box interface for caif shared memory transport

	                want
	End above sentence with a period.

> +	Mainly used for debugging and as example driver
> +	This can also be built as a module

Ditto.

> +
> +endif #CAIF_USE_SHM
> +
> +endif # CAIF



---
~Randy
