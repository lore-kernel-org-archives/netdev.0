From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH 1/3] netdevice: provide common routine for macvlan and vlan operstate management
Date: Fri, 27 Nov 2009 14:09:28 +0100
Message-ID: <200911271409.28810.arnd@arndb.de>
References: <20091113195201.11184.25766.stgit@mimic.site> <20091113195513.11184.63631.stgit@mimic.site>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, netdev@vger.kernel.org,
	alacrityvm-devel@lists.sourceforge.net,
	linux-kernel@vger.kernel.org, bridge@lists.linux-foundation.org
To: Patrick Mullaney <pmullaney@novell.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.187]:65004 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751216AbZK0NJl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Nov 2009 08:09:41 -0500
In-Reply-To: <20091113195513.11184.63631.stgit@mimic.site>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Friday 13 November 2009, Patrick Mullaney wrote:
> @@ -551,7 +532,7 @@ static int macvlan_newlink(struct net_device *dev,
>                 return err;
>  
>         list_add_tail(&vlan->list, &port->vlans);
> -       macvlan_transfer_operstate(dev);
> +       netif_stacked_transfer_operstate(dev, lowerdev);
>         return 0;
>  }
>  
> @@ -591,7 +572,8 @@ static int macvlan_device_event(struct notifier_block *unused,
>         switch (event) {
>         case NETDEV_CHANGE:
>                 list_for_each_entry(vlan, &port->vlans, list)
> -                       macvlan_transfer_operstate(vlan->dev);
> +                       netif_stacked_transfer_operstate(vlan->dev,
> +                                                        vlan->lowerdev);
>                 break;
>         case NETDEV_FEAT_CHANGE:
>                 list_for_each_entry(vlan, &port->vlans, list) {

These have the arguments reversed, lowerdev should come first.

	Arnd <><
