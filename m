From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 6/7] netxen: add module parameters
Date: Thu, 14 Aug 2008 04:46:24 -0400
Message-ID: <48A3F0E0.6060006@garzik.org>
References: <> <1218179325-32493-7-git-send-email-dhananjay@netxen.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Dhananjay Phadke <dhananjay@netxen.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:36300 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754907AbYHNIq1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Aug 2008 04:46:27 -0400
In-Reply-To: <1218179325-32493-7-git-send-email-dhananjay@netxen.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dhananjay Phadke wrote:
> Add user tunable params to enable/disable msi/msix, port auto-neg modes.
> 
> Signed-off-by: Dhananjay Phadke <dhananjay@netxen.com>
> ---
>  drivers/net/netxen/netxen_nic_main.c |   10 +++++++++-
>  1 files changed, 9 insertions(+), 1 deletions(-)
> 
> diff --git a/drivers/net/netxen/netxen_nic_main.c b/drivers/net/netxen/netxen_nic_main.c
> index 3c424a8..ee56511 100644
> --- a/drivers/net/netxen/netxen_nic_main.c
> +++ b/drivers/net/netxen/netxen_nic_main.c
> @@ -50,13 +50,21 @@ static char netxen_nic_driver_string[] = "NetXen Network Driver version "
>      NETXEN_NIC_LINUX_VERSIONID;
>  
>  static int port_mode = NETXEN_PORT_MODE_AUTO_NEG;
> +module_param(port_mode, int, 0);
> +MODULE_PARM_DESC(port_mode, "Force port mode Auto-Neg XG, 1G or XG");
>  
>  /* Default to restricted 1G auto-neg mode */
> -static int wol_port_mode = 5;
> +static int wol_port_mode = NETXEN_PORT_MODE_AUTO_NEG_1G;
> +module_param(wol_port_mode, int, 0);
> +MODULE_PARM_DESC(wol_port_mode, "Force WOL port mode XG, 1G or Auto-Neg");
>  
>  static int use_msi = 1;
> +module_param(use_msi, bool, 0);
> +MODULE_PARM_DESC(use_msi, "Enable or disable MSI interrupts");
>  
>  static int use_msi_x = 1;
> +module_param(use_msi_x, bool, 0);
> +MODULE_PARM_DESC(use_msi_x, "Enable or disable MSI-X interrupts");

typically it is preferred not add module parameters for each type of 
setting.  drivers should auto-configure themselves, modulo PCI quirks 
and the like.


