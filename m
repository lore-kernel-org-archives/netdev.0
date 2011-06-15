From: Antoine Reversat <a.reversat@gmail.com>
Subject: Re: [PATCH 001/001] forcedeth: Don't enable hardware vlan support on
 hardware that doesn't support it
Date: Wed, 15 Jun 2011 17:08:18 -0400
Message-ID: <BANLkTimqAXLDZ8cev5dgUTDR3pg-_Y3XUA@mail.gmail.com>
References: <25664046.71236.1308171027618.JavaMail.root@tahiti.vyatta.com>
	<585670083.71238.1308171180725.JavaMail.root@tahiti.vyatta.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen.hemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:37545 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751982Ab1FOVIT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Jun 2011 17:08:19 -0400
Received: by bwz15 with SMTP id 15so804242bwz.19
        for <netdev@vger.kernel.org>; Wed, 15 Jun 2011 14:08:18 -0700 (PDT)
In-Reply-To: <585670083.71238.1308171180725.JavaMail.root@tahiti.vyatta.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 15, 2011 at 4:53 PM, Stephen Hemminger
<stephen.hemminger@vyatta.com> wrote:
>
> This shouldn't be necessary. rx_register should not be called
> unless NETIF_F_HW_VLAN_RX is set; and device should not be setting
> NETIF_F_HW_VLAN_RX unless DEV_HAS_VLAN is set.

I can confirm that rx_register gets called on hardware that doesn't
have vlan support (namely MCP79).

>From what I can see in vlan.c (in register_vlan_dev) there is no check
on the features of the device before calling the register function :

    if (ngrp) {
        if (ops->ndo_vlan_rx_register)
            ops->ndo_vlan_rx_register(real_dev, ngrp);
        rcu_assign_pointer(real_dev->vlgrp, ngrp);
    }

If the function exists, it's called. Should I send a patch to call the
function only if the hardware supports it ?

>
> The real problem is vlan_dev.c, and applies to all devices.
>
>
