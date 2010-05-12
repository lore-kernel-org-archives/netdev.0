From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: [RFC PATCH] bnx2: use netif_carrier_off to prevent tx
 timeout
Date: Wed, 12 May 2010 07:09:16 -0700
Message-ID: <C27F8246C663564A84BB7AB3439772421B6C41FC57@IRVEXCHCCR01.corp.ad.broadcom.com>
References: <20100512160036.1f69fd23@dhcp-lab-109.englab.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Eric Dumazet" <eric.dumazet@gmail.com>,
	"Eilon Greenstein" <eilong@broadcom.com>,
	"Vladislav Zolotarov" <vladz@broadcom.com>,
	"Dmitry Kravkov" <dmitry@broadcom.com>,
	"Breno Leitao" <leitao@linux.vnet.ibm.com>,
	"Matthew Carlson" <mcarlson@broadcom.com>
To: "'Stanislaw Gruszka'" <sgruszka@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:2535 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755865Ab0ELOJZ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 May 2010 10:09:25 -0400
In-Reply-To: <20100512160036.1f69fd23@dhcp-lab-109.englab.brq.redhat.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stanislaw Gruszka wrote:

> On Wed, 12 May 2010 06:31:52 -0700
> "Michael Chan" <mchan@broadcom.com> wrote:
>
> > > @@ -6346,6 +6338,8 @@ bnx2_vlan_rx_register(struct net_device
> > > *dev, struct vlan_group *vlgrp)
> > >       if (bp->flags & BNX2_FLAG_CAN_KEEP_VLAN)
> > >               bnx2_fw_sync(bp,
> > > BNX2_DRV_MSG_CODE_KEEP_VLAN_UPDATE, 0, 1);
> > >
> > > +     if (bp->link_up)
> > > +             netif_carrier_on(bp->dev);
> >
> > Thanks Stanislaw, I think it is better to turn carrier on in
> > bnx2_netif_start().  We can use the start_cnic parameter to
> > decide if we need to call carrier_on().
>
> IIRC in most cases we set carrier status in bnx2_init_nic()
> (based on what we get from PHY) called before bnx2_netif_start().
> One exception is bnx2_vlan_rx_register() function.
>

Yes, if we reset the chip and reset the PHY, we'll always get a
link up event and we'll set carrier.  We need to take care of
the cases where the chip is not reset or the phy is not reset.
I think it is better if the caller of bnx2_netif_start() does
not have to worry about setting the carrier.

