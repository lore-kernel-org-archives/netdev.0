From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: Re: [PATCH 1/4] atl1: Build files for Attansic L1 driver
Date: Sun, 19 Nov 2006 15:24:32 -0800
Message-ID: <20061119152432.a85d4166.randy.dunlap@oracle.com>
References: <20061119202915.GB29736@osprey.hogchain.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, shemminger@osdl.org, romieu@fr.zoreil.com,
	csnook@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:24052 "EHLO
	rgminet01.oracle.com") by vger.kernel.org with ESMTP
	id S933715AbWKSX2G (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 19 Nov 2006 18:28:06 -0500
To: Jay Cliburn <jacliburn@bellsouth.net>
In-Reply-To: <20061119202915.GB29736@osprey.hogchain.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 19 Nov 2006 14:29:15 -0600 Jay Cliburn wrote:

> From: Jay Cliburn <jacliburn@bellsouth.net>
> 
> This patch contains the build files for the Attansic L1 gigabit ethernet
> adapter driver.
> 
> Signed-off-by: Jay Cliburn <jacliburn@bellsouth.net>
> ---
> 
>  Kconfig       |   12 ++++++++++++
>  Makefile      |    1 +
>  atl1/Makefile |   30 ++++++++++++++++++++++++++++++
>  3 files changed, 43 insertions(+)
> 
> diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
> index 6e863aa..f503d10 100644
> --- a/drivers/net/Kconfig
> +++ b/drivers/net/Kconfig
> @@ -2329,6 +2329,18 @@ config QLA3XXX
>  	  To compile this driver as a module, choose M here: the module
>  	  will be called qla3xxx.
>  
> +config ATL1
> +	tristate "Attansic(R) L1 Gigabit Ethernet support (EXPERIMENTAL)"
> +	depends on NET_PCI && PCI && EXPERIMENTAL
> +	select CRC32
> +	select MII
> +	---help---
> +	  This driver supports Attansic L1 gigabit ethernet adapter.
> +
> +	  To compile this driver as a module, choose M here.  The module
> +	  will be called atl1.
> +
> +
>  endmenu

One problem here is that MII depends on NET_ETHERNET, which is
10/100 ethernet, which may not be enabled if someone has only
gigabit ethernet.  :)

I have a partial patch which moves MII and PHYLIB outside of
NET_ETHERNET.  That also makes them usable by USB or other
non-drivers/net/ drivers, e.g., again without the need
to enable NET_ETHERNET if someone only has USB ethernet.  :(

I'll try to post it for review later today.

---
~Randy
