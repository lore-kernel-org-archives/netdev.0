From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] convert wan/lmc to device model
Date: Sat, 20 Sep 2003 13:47:31 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3F6C92B3.3060603@pobox.com>
References: <20030916143627.51a08be0.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20030916143627.51a08be0.shemminger@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:
> This patch converts drivers/net/wan/lmc for 2.6.0-test5
> 	- use pci_device model
> 	- get rid of MOD_INC/DEC
> 	- use alloc_netdev and dev->priv for private data
> 
> Builds and loads but don't have real hardware.
> 
> diff -Nru a/drivers/net/wan/lmc/lmc_main.c b/drivers/net/wan/lmc/lmc_main.c
> --- a/drivers/net/wan/lmc/lmc_main.c	Tue Sep 16 14:33:16 2003
> +++ b/drivers/net/wan/lmc/lmc_main.c	Tue Sep 16 14:33:16 2003
> @@ -78,30 +78,20 @@
>  #include "lmc_debug.h"
>  #include "lmc_proto.h"
>  
> -
> -static int Lmc_Count = 0;
> -static struct net_device *Lmc_root_dev = NULL;
> -static u8 cards_found = 0;
> -
>  static int lmc_first_load = 0;
>  
> -int LMC_PKT_BUF_SZ = 1542;
> +static int LMC_PKT_BUF_SZ = 1542;
>  
> -#ifdef MODULE
>  static struct pci_device_id lmc_pci_tbl[] = {
> -    { 0x1011, 0x009, 0x1379, PCI_ANY_ID, 0, 0, 0},
> -    { 0, }
> +	{ CORRECT_VENDOR_ID, CORRECT_DEV_ID, PCI_VENDOR_LMC, PCI_ANY_ID },
> +	{ CORRECT_VENDOR_ID, CORRECT_DEV_ID, PCI_ANY_ID, PCI_VENDOR_LMC },
> +	{ 0 }


Um, this is majorly ugly.  I know you didn't create the CORRECT_xxx 
constants... but let's not use them.  Either use the hex constants 
directly, or update pci_ids.h and use the constants from there.

	Jeff
