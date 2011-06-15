From: Stephen Hemminger <stephen.hemminger@vyatta.com>
Subject: Re: [PATCH 001/001] forcedeth: Don't enable hardware vlan support
 on hardware that doesn't support it
Date: Wed, 15 Jun 2011 13:53:00 -0700 (PDT)
Message-ID: <585670083.71238.1308171180725.JavaMail.root@tahiti.vyatta.com>
References: <25664046.71236.1308171027618.JavaMail.root@tahiti.vyatta.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Antoine Reversat <a.reversat@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:51969 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753444Ab1FOUxE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 Jun 2011 16:53:04 -0400
In-Reply-To: <25664046.71236.1308171027618.JavaMail.root@tahiti.vyatta.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> In the forcedeth driver hardware vlan support is used even on hardware
> that doesn't support it leading to incorrect tagging of some packets
> when using vlan.
> 
> Signed-off-by: Antoine Reversat <a.reversat@gmail.com>
> ---
> --- linux-2.6.39/drivers/net/forcedeth.c 2011-05-19 00:06:34.000000000
> -0400 +++ linux-2.6.39-fixed/drivers/net/forcedeth.c 2011-06-15
> 15:57:45.331158001 -0400
> @@ -4915,6 +4915,10 @@ static void nv_vlan_rx_register(struct n
> { struct fe_priv *np = get_nvpriv(dev);
> 
> + /* Don't do anything if device doesn't support VLAN */
> + if (!(np->driver_data & DEV_HAS_VLAN))
> + return;
> + spin_lock_irq(&np->lock);
> 
> /* save vlan group */

This shouldn't be necessary. rx_register should not be called
unless NETIF_F_HW_VLAN_RX is set; and device should not be setting
NETIF_F_HW_VLAN_RX unless DEV_HAS_VLAN is set.

The real problem is vlan_dev.c, and applies to all devices.

