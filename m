From: Stanislaw Gruszka <sgruszka@redhat.com>
Subject: Re: [RFC PATCH] bnx2: use netif_carrier_off to prevent tx timeout
Date: Wed, 12 May 2010 16:00:36 +0200
Message-ID: <20100512160036.1f69fd23@dhcp-lab-109.englab.brq.redhat.com>
References: <20100512130628.69bc3890@dhcp-lab-109.englab.brq.redhat.com>
	<C27F8246C663564A84BB7AB3439772421B6C41FC55@IRVEXCHCCR01.corp.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Eric Dumazet" <eric.dumazet@gmail.com>,
	"Eilon Greenstein" <eilong@broadcom.com>,
	"Vladislav Zolotarov" <vladz@broadcom.com>,
	"Dmitry Kravkov" <dmitry@broadcom.com>,
	"Breno Leitao" <leitao@linux.vnet.ibm.com>,
	"Matthew Carlson" <mcarlson@broadcom.com>
To: "Michael Chan" <mchan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:22653 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755125Ab0ELN6d (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 May 2010 09:58:33 -0400
In-Reply-To: <C27F8246C663564A84BB7AB3439772421B6C41FC55@IRVEXCHCCR01.corp.ad.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 12 May 2010 06:31:52 -0700
"Michael Chan" <mchan@broadcom.com> wrote:

> > @@ -6346,6 +6338,8 @@ bnx2_vlan_rx_register(struct net_device
> > *dev, struct vlan_group *vlgrp)
> >       if (bp->flags & BNX2_FLAG_CAN_KEEP_VLAN)
> >               bnx2_fw_sync(bp,
> > BNX2_DRV_MSG_CODE_KEEP_VLAN_UPDATE, 0, 1);
> >
> > +     if (bp->link_up)
> > +             netif_carrier_on(bp->dev);
> 
> Thanks Stanislaw, I think it is better to turn carrier on in
> bnx2_netif_start().  We can use the start_cnic parameter to
> decide if we need to call carrier_on().

IIRC in most cases we set carrier status in bnx2_init_nic()
(based on what we get from PHY) called before bnx2_netif_start().
One exception is bnx2_vlan_rx_register() function.

Thanks
Stanislaw
