From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH 001/001] forcedeth: Don't enable hardware vlan support
 on hardware that doesn't support it
Date: Thu, 16 Jun 2011 08:42:38 -0700
Message-ID: <20110616084238.7830cd92@nehalam.ftrdhcpuser.net>
References: <25664046.71236.1308171027618.JavaMail.root@tahiti.vyatta.com>
	<585670083.71238.1308171180725.JavaMail.root@tahiti.vyatta.com>
	<BANLkTimqAXLDZ8cev5dgUTDR3pg-_Y3XUA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <stephen.hemminger@vyatta.com>,
	netdev@vger.kernel.org
To: Antoine Reversat <a.reversat@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:39720 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754831Ab1FPPmu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 16 Jun 2011 11:42:50 -0400
In-Reply-To: <BANLkTimqAXLDZ8cev5dgUTDR3pg-_Y3XUA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 15 Jun 2011 17:08:18 -0400
Antoine Reversat <a.reversat@gmail.com> wrote:

> On Wed, Jun 15, 2011 at 4:53 PM, Stephen Hemminger
> <stephen.hemminger@vyatta.com> wrote:
> >
> > This shouldn't be necessary. rx_register should not be called
> > unless NETIF_F_HW_VLAN_RX is set; and device should not be setting
> > NETIF_F_HW_VLAN_RX unless DEV_HAS_VLAN is set.
> 
> I can confirm that rx_register gets called on hardware that doesn't
> have vlan support (namely MCP79).
> 
> From what I can see in vlan.c (in register_vlan_dev) there is no check
> on the features of the device before calling the register function :
> 
>     if (ngrp) {
>         if (ops->ndo_vlan_rx_register)
>             ops->ndo_vlan_rx_register(real_dev, ngrp);
>         rcu_assign_pointer(real_dev->vlgrp, ngrp);
>     }
> 
> If the function exists, it's called. Should I send a patch to call the
> function only if the hardware supports it ?
> 
> >
> > The real problem is vlan_dev.c, and applies to all devices.

That is was suggesting because other drivers may have the same issue
where they need to define rx_register for some hardware and control
usage of vlan by the feature bits.
