From: Rajesh Borundia <rajesh.borundia@qlogic.com>
Subject: RE: [PATCH net-next] netxen: fix link notification order
Date: Thu, 12 Jul 2012 01:27:50 -0500
Message-ID: <13A253B3F9BEFE43B93C09CF75F63CAA81A934387E@MNEXMB1.qlogic.org>
References: <1342033015-31442-1-git-send-email-fbl@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Sony Chacko <sony.chacko@qlogic.com>
To: Flavio Leitner <fbl@redhat.com>, netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from co1ehsobe003.messaging.microsoft.com ([216.32.180.186]:5494
	"EHLO co1outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756640Ab2GLG2F convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 Jul 2012 02:28:05 -0400
In-Reply-To: <1342033015-31442-1-git-send-email-fbl@redhat.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: Flavio Leitner [mailto:fbl@redhat.com]
> Sent: Thursday, July 12, 2012 12:27 AM
> To: netdev
> Cc: Sony Chacko; Rajesh Borundia; Flavio Leitner
> Subject: [PATCH net-next] netxen: fix link notification order
> 
> First update the adapter variables with the current speed and
> mode before fire the notification. Otherwise, the get_settings()
> may provide old values.
> 
> Signed-off-by: Flavio Leitner <fbl@redhat.com>
> ---
>  drivers/net/ethernet/qlogic/netxen/netxen_nic_init.c |    4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/net/ethernet/qlogic/netxen/netxen_nic_init.c
> b/drivers/net/ethernet/qlogic/netxen/netxen_nic_init.c
> index b2c1b676..bc165f4 100644
> --- a/drivers/net/ethernet/qlogic/netxen/netxen_nic_init.c
> +++ b/drivers/net/ethernet/qlogic/netxen/netxen_nic_init.c
> @@ -1437,8 +1437,6 @@ netxen_handle_linkevent(struct netxen_adapter
> *adapter, nx_fw_msg_t *msg)
>  				netdev->name, cable_len);
>  	}
> 
> -	netxen_advert_link_change(adapter, link_status);
> -
>  	/* update link parameters */
>  	if (duplex == LINKEVENT_FULL_DUPLEX)
>  		adapter->link_duplex = DUPLEX_FULL;
> @@ -1447,6 +1445,8 @@ netxen_handle_linkevent(struct netxen_adapter
> *adapter, nx_fw_msg_t *msg)
>  	adapter->module_type = module;
>  	adapter->link_autoneg = autoneg;
>  	adapter->link_speed = link_speed;
> +
> +	netxen_advert_link_change(adapter, link_status);
>  }
> 
>  static void
> --
> 1.7.10.4
> 
Acked-by: Rajesh Borundia <rajesh.borundia@qlogic.com>
