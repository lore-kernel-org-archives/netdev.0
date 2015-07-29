From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [net-next PATCH 2/2] drivers: net: cpsw: add separate napi for
 tx packet handling for performance improvment
Date: Thu, 30 Jul 2015 00:57:09 +0200
Message-ID: <20150729225709.GA8122@electric-eye.fr.zoreil.com>
References: <1437995941-5857-1-git-send-email-mugunthanvnm@ti.com>
 <1437995941-5857-3-git-send-email-mugunthanvnm@ti.com>
 <20150727212206.GA8912@electric-eye.fr.zoreil.com>
 <55B71E99.50807@ti.com>
 <20150728223013.GA10669@electric-eye.fr.zoreil.com>
 <55B86240.4090301@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Mugunthan V N <mugunthanvnm@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:51941 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752025AbbG2W5c (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Jul 2015 18:57:32 -0400
Content-Disposition: inline
In-Reply-To: <55B86240.4090301@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mugunthan V N <mugunthanvnm@ti.com> :
> On Wednesday 29 July 2015 04:00 AM, Francois Romieu wrote:
> > Mugunthan V N <mugunthanvnm@ti.com> :
> >> On Tuesday 28 July 2015 02:52 AM, Francois Romieu wrote:
[...]
> >>> cpsw_ndo_stop calls napi_disable: you can remove netif_running.
> >>>
> >>
> >> This netif_running check is to find which interface is up as the
> >> interrupt is shared by both the interfaces. When first interface is down
> >> and second interface is active then napi_schedule for first interface
> >> will fail and second interface napi needs to be scheduled.
> >>
> >> So I don't think netif_running needs to be removed.
> > 
> > Each interface has its own napi tx (resp. rx) context: I would had expected
> > two unconditional napi_schedule per tx (resp. rx) shared irq, not one.
> > 
> > I'll read it again after some sleep.
> > 
> 
> For each interrupt only one napi will be scheduled, when the first
> interface is down then only second interface napi is scheduled in both
> tx and rx irqs.

Ok, I've had some hints from the "Assumptions" section at
http://processors.wiki.ti.com/index.php/AM335x_CPSW_%28Ethernet%29_Driver%27s_Guide#Dual_Standalone_EMAC_mode

Why does the driver create 2 rx napi contexts ? They don't run at the
same time and the port demux is done in cpsw_dual_emac_src_port_detect.
The driver would work the same with a single rx (resp. tx) napi context
for both interfaces.

-- 
Ueimor
