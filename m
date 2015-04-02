From: Bob Cochran <ppc@mindchasers.com>
Subject: Re: [RFC,v2,02/12] soc/fman: Add the FMan FLIB
Date: Thu, 02 Apr 2015 11:48:21 -0400
Message-ID: <551D64C5.7040607@mindchasers.com>
References: <1427888168-24145-1-git-send-email-igal.liberman@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: scottwood@freescale.com, madalin.bucur@freescale.com
To: "Igal.Liberman" <igal.liberman@freescale.com>,
	linuxppc-dev@lists.ozlabs.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from resqmta-ch2-09v.sys.comcast.net ([69.252.207.41]:42176 "EHLO
	resqmta-ch2-09v.sys.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752922AbbDBP4g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Apr 2015 11:56:36 -0400
In-Reply-To: <1427888168-24145-1-git-send-email-igal.liberman@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/01/2015 07:36 AM, Igal.Liberman wrote:
> From: Igal Liberman <Igal.Liberman@freescale.com>
>
> The FMan FLib provides the basic API used by the FMan drivers to
> configure and control the FMan hardware.
>
> Signed-off-by: Igal Liberman <Igal.Liberman@freescale.com>
> ---
>   drivers/soc/fsl/Kconfig       |    2 +
>   drivers/soc/fsl/Makefile      |    2 +
>   drivers/soc/fsl/fman/Kconfig  |    7 +
>   drivers/soc/fsl/fman/Makefile |    5 +
>   drivers/soc/fsl/fman/fman.c   |  978 +++++++++++++++++++++++++++++++++++++++++
>   5 files changed, 994 insertions(+)
>   create mode 100644 drivers/soc/fsl/fman/Kconfig
>   create mode 100644 drivers/soc/fsl/fman/Makefile
>   create mode 100644 drivers/soc/fsl/fman/fman.c
>
> diff --git a/drivers/soc/fsl/Kconfig b/drivers/soc/fsl/Kconfig
> index 291123a..2981306 100644
> --- a/drivers/soc/fsl/Kconfig
> +++ b/drivers/soc/fsl/Kconfig


I need some help putting together the DPAA patches.  On 3/11, there was 
a patch with the subject "[v2,02/11] soc/fman: Add the FMan FLIB", which 
is basically the same subject as this one.  In the 3/11 patch, you 
create /drivers/soc/fsl/Kconfig and Makefile.

In this patch, Kconfig and Makefile already exist.  So, please tell me 
the patch that should be applied before this one to pick up both Kconfig 
and Makefile.

Should this patch have been called v3?  There was a v1 on 3/5 and a v2 
on 3/11 that had the subject "soc/fman Add the FMan FLIB".

Excluding device tree patches, I think there are currently three 
non-superseded patch sets submitted for the DPAA:

1) 4/1/15: [PATCH RFC 00/10] introduce DPAA Ethernet driver, 
madalin.bucur@freescale.com  [SHOULD HAVE BEEN TITLED V2?]

2) 4/1/15: [RFC,v2,00/12] Freescale DPAA FMan, 
igal.liberman@freescale.com [SHOULD HAVE BEEN TITLED V3?]

3) 3/9/15: [RFC v3 00/10] Freescale DPAA B/QMan drivers, 
Emilian.Medve@Freescale.com


I'm looking forward to putting together all the patches and trying to 
build it and eventually test it.


Thank you,

Bob




> @@ -189,4 +189,6 @@ config FSL_QMAN_INIT_TIMEOUT
>
>   endif # FSL_QMAN
>
> +source "drivers/soc/fsl/fman/Kconfig"
> +
>   endif # FSL_DPA
> diff --git a/drivers/soc/fsl/Makefile b/drivers/soc/fsl/Makefile
> index cce1f70..b2f76e9 100644
> --- a/drivers/soc/fsl/Makefile
> +++ b/drivers/soc/fsl/Makefile
> @@ -18,3 +18,5 @@ qman-test-y					 = qman_test.o
>   qman-test-$(CONFIG_FSL_QMAN_TEST_API)		+= qman_test_api.o
>   qman-test-$(CONFIG_FSL_QMAN_TEST_STASH)		+= qman_test_stash.o
>   obj-$(CONFIG_FSL_QMAN_DEBUGFS)			+= qman-debugfs.o
> +
> +obj-$(CONFIG_FSL_FMAN)				+= fman/
> diff --git a/drivers/soc/fsl/fman/Kconfig b/drivers/soc/fsl/fman/Kconfig
> new file mode 100644
> index 0000000..8aeae29
> --- /dev/null
> +++ b/drivers/soc/fsl/fman/Kconfig
> @@ -0,0 +1,7 @@
> +config FSL_FMAN
> +	bool "FMan support"
> +	depends on FSL_SOC || COMPILE_TEST
> +	default n
> +	help
> +		Freescale Data-Path Acceleration Architecture Frame Manager
> +		(FMan) support
>

[snip]
