From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: Re: [RFC net-next 07/14] Fix intel/ixgbe
Date: Tue, 19 Jun 2012 19:11:50 +0300
Message-ID: <1340122310.2486.16.camel@lb-tlvb-eilong.il.broadcom.com>
References: <1340118848-30978-1-git-send-email-yuvalmin@broadcom.com>
 <1340118848-30978-8-git-send-email-yuvalmin@broadcom.com>
 <4FE0A0CD.5050909@intel.com>
Reply-To: eilong@broadcom.com
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "Yuval Mintz" <yuvalmin@broadcom.com>, netdev@vger.kernel.org,
	davem@davemloft.net, "Jeff Kirsher" <jeffrey.t.kirsher@intel.com>
To: "Alexander Duyck" <alexander.h.duyck@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:4991 "EHLO mms3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752044Ab2FSQMD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Jun 2012 12:12:03 -0400
In-Reply-To: <4FE0A0CD.5050909@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-06-19 at 08:54 -0700, Alexander Duyck wrote:
> On 06/19/2012 08:14 AM, Yuval Mintz wrote:
> > Signed-off-by: Yuval Mintz <yuvalmin@broadcom.com>
> > Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
> >
> > Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> > ---
> >  drivers/net/ethernet/intel/ixgbe/ixgbe_lib.c |    3 ++-
> >  1 files changed, 2 insertions(+), 1 deletions(-)
> >
> > diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_lib.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_lib.c
> > index af1a531..21e4513 100644
> > --- a/drivers/net/ethernet/intel/ixgbe/ixgbe_lib.c
> > +++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_lib.c
> > @@ -802,7 +802,8 @@ static int ixgbe_set_interrupt_capability(struct ixgbe_adapter *adapter)
> >  	 * The default is to use pairs of vectors.
> >  	 */
> >  	v_budget = max(adapter->num_rx_queues, adapter->num_tx_queues);
> > -	v_budget = min_t(int, v_budget, num_online_cpus());
> > +	v_budget = min_t(int, v_budget, min_t(int, num_online_cpus(),
> > +					      DEFAULT_MAX_NUM_RSS_QUEUES));
> >  	v_budget += NON_Q_VECTORS;
> >  
> >  	/*
> This patch doesn't limit the number of queues.  It is limiting the
> number of interrupts.  The two are not directly related as we can
> support multiple queues per interrupt.
> 
> Also this change assumes we are only using receive side scaling.  We
> have other features such as DCB, FCoE, and Flow Director which require
> additional queues.

You are right - but DEFAULT_MAX_NUM_RSS_QUEUES is there to limit the RSS
and not everything else. It is harder to determine what else should be
set to a lower value and the two goals were to limit the memory waste in
correlation to the number of CPUs and to have some unification between
the drivers - both goals are applicable mostly to the RSS and not so
much to DCB, FCoE and similar features.

Thanks,
Eilon
