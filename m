From: Andy Gospodarek <andy@greyhouse.net>
Subject: Re: [PATCH net-next 1/6] [BNX2]: Allow phy reset to be skipped during chip reset.
Date: Fri, 16 May 2008 17:34:30 -0400
Message-ID: <20080516213430.GC20212@gospo.usersys.redhat.com>
References: <1210973376.5507.17.camel@dell>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org, andy@greyhouse.net,
	benli@broadcom.com
To: Michael Chan <mchan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:54846 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751075AbYEPVeg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 16 May 2008 17:34:36 -0400
Content-Disposition: inline
In-Reply-To: <1210973376.5507.17.camel@dell>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 16, 2008 at 02:29:36PM -0700, Michael Chan wrote:
> [BNX2]: Allow phy reset to be skipped during chip reset.
> 
> Andy Gospodarek <andy@greyhouse.net> found that netconsole would
> panic when resetting bnx2 devices.
> 
> >From Andy:
> "The issue is the bnx2_set_link in bnx2_init_nic will print a link-status
> message before we are fully initialized and ready to start polling.
> Polling is currently disabled in this state, but since the
> __LINK_STATE_RX_SCHED is overloaded to not only try and disable polling
> but also to make the system aware there is something waiting to be
> polled, we really have to fix this in drivers.
> 
> The problematic call is the one to netif_rx_complete as it tries to
> remove an entry from the poll_list when there isn't one."
> 
> While this netconsole problem should be fixed separately, we really
> should not reset the PHY when changing ring sizes, MTU, or other
> similar settings.  The PHY reset causes several seconds of unnecessary
> link disruptions.
> 
> Signed-off-by: Michael Chan <mchan@broadcom.com>
> Cc: Andy Gospodarek <andy@greyhouse.net>

Acked-by: Andy Gospodarek <andy@greyhouse.net>

