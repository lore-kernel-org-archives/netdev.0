From: "Jan Beulich" <JBeulich@novell.com>
Subject: Re: [PATCH] cxgb{3,4}*: improve Kconfig dependencies
Date: Tue, 01 Mar 2011 07:46:32 +0000
Message-ID: <4D6CB26802000078000343BD@vpn.id2.novell.com>
References: <1298950455-4497-1-git-send-email-dm@chelsio.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8BIT
Cc: <linux-scsi@vger.kernel.org>, <netdev@vger.kernel.org>
To: "Dimitris Michailidis" <dm@chelsio.com>
Return-path: <linux-scsi-owner@vger.kernel.org>
In-Reply-To: <1298950455-4497-1-git-send-email-dm@chelsio.com>
Content-Disposition: inline
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>>> On 01.03.11 at 04:34, Dimitris Michailidis <dm@chelsio.com> wrote:
> - Remove the dependency of cxgb4 and cxgb4vf on INET.  cxgb3 really
>   depends on INET, keep it but add it directly to the driver's Kconfig
>   entry.
> - Make the iSCSI drivers cxgb3i and cxgb4i available in the SCSI menu
>   without requiring any options in the net driver menu to be enabled
>   first.  Add needed selects so the iSCSI drivers can build their
>   corresponding net drivers.
> - Remove CHELSIO_T*_DEPENDS.
> 
> Signed-off-by: Dimitris Michailidis <dm@chelsio.com>
> ---
>  drivers/net/Kconfig               |   21 +++------------------
>  drivers/scsi/cxgbi/cxgb3i/Kconfig |    4 +++-
>  drivers/scsi/cxgbi/cxgb4i/Kconfig |    4 +++-
>  3 files changed, 9 insertions(+), 20 deletions(-)
> 
> diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
> index f4b3927..6e09d5f 100644
> --- a/drivers/net/Kconfig
> +++ b/drivers/net/Kconfig
> @@ -2595,14 +2595,9 @@ config CHELSIO_T1_1G
>  	  Enables support for Chelsio's gigabit Ethernet PCI cards.  If you
>  	  are using only 10G cards say 'N' here.
>  
> -config CHELSIO_T3_DEPENDS
> -	tristate
> -	depends on PCI && INET
> -	default y
> -
>  config CHELSIO_T3
>  	tristate "Chelsio Communications T3 10Gb Ethernet support"
> -	depends on CHELSIO_T3_DEPENDS
> +	depends on PCI && INET

Forgot to remove INET here?

Besides that,
Acked-by: Jan Beulich <jbeulich@novell.com>

>  	select FW_LOADER
>  	select MDIO
>  	help
> @@ -2620,14 +2615,9 @@ config CHELSIO_T3
>  	  To compile this driver as a module, choose M here: the module
>  	  will be called cxgb3.
>  
> -config CHELSIO_T4_DEPENDS
> -	tristate
> -	depends on PCI && INET
> -	default y
> -
>  config CHELSIO_T4
>  	tristate "Chelsio Communications T4 Ethernet support"
> -	depends on CHELSIO_T4_DEPENDS
> +	depends on PCI
>  	select FW_LOADER
>  	select MDIO
>  	help
> @@ -2645,14 +2635,9 @@ config CHELSIO_T4
>  	  To compile this driver as a module choose M here; the module
>  	  will be called cxgb4.
>  
> -config CHELSIO_T4VF_DEPENDS
> -	tristate
> -	depends on PCI && INET
> -	default y
> -
>  config CHELSIO_T4VF
>  	tristate "Chelsio Communications T4 Virtual Function Ethernet support"
> -	depends on CHELSIO_T4VF_DEPENDS
> +	depends on PCI
>  	help
>  	  This driver supports Chelsio T4-based gigabit and 10Gb Ethernet
>  	  adapters with PCI-E SR-IOV Virtual Functions.
> diff --git a/drivers/scsi/cxgbi/cxgb3i/Kconfig 
> b/drivers/scsi/cxgbi/cxgb3i/Kconfig
> index 5cf4e98..11dff23 100644
> --- a/drivers/scsi/cxgbi/cxgb3i/Kconfig
> +++ b/drivers/scsi/cxgbi/cxgb3i/Kconfig
> @@ -1,6 +1,8 @@
>  config SCSI_CXGB3_ISCSI
>  	tristate "Chelsio T3 iSCSI support"
> -	depends on CHELSIO_T3_DEPENDS
> +	depends on PCI && INET
> +	select NETDEVICES
> +	select NETDEV_10000
>  	select CHELSIO_T3
>  	select SCSI_ISCSI_ATTRS
>  	---help---
> diff --git a/drivers/scsi/cxgbi/cxgb4i/Kconfig 
> b/drivers/scsi/cxgbi/cxgb4i/Kconfig
> index bb94b39..d5302c2 100644
> --- a/drivers/scsi/cxgbi/cxgb4i/Kconfig
> +++ b/drivers/scsi/cxgbi/cxgb4i/Kconfig
> @@ -1,6 +1,8 @@
>  config SCSI_CXGB4_ISCSI
>  	tristate "Chelsio T4 iSCSI support"
> -	depends on CHELSIO_T4_DEPENDS
> +	depends on PCI && INET
> +	select NETDEVICES
> +	select NETDEV_10000
>  	select CHELSIO_T4
>  	select SCSI_ISCSI_ATTRS
>  	---help---




