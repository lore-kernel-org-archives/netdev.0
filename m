From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: Re: [RFC net-next 05/14] Fix intel/ixgbevf
Date: Tue, 19 Jun 2012 19:06:53 +0300
Message-ID: <1340122013.2486.14.camel@lb-tlvb-eilong.il.broadcom.com>
References: <1340118848-30978-1-git-send-email-yuvalmin@broadcom.com>
 <1340118848-30978-6-git-send-email-yuvalmin@broadcom.com>
 <4FE09D3F.4060305@intel.com>
Reply-To: eilong@broadcom.com
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "Yuval Mintz" <yuvalmin@broadcom.com>, netdev@vger.kernel.org,
	davem@davemloft.net, "Jeff Kirsher" <jeffrey.t.kirsher@intel.com>
To: "Alexander Duyck" <alexander.h.duyck@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:2604 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751508Ab2FSQHH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Jun 2012 12:07:07 -0400
In-Reply-To: <4FE09D3F.4060305@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-06-19 at 08:39 -0700, Alexander Duyck wrote:
> On 06/19/2012 08:13 AM, Yuval Mintz wrote:
> > Signed-off-by: Yuval Mintz <yuvalmin@broadcom.com>
> > Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
> >
> > Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> > ---
> >  drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c |    5 +++--
> >  1 files changed, 3 insertions(+), 2 deletions(-)
> >
> > diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
> > index f69ec42..3ad46c2 100644
> > --- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
> > +++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
> > @@ -2014,7 +2014,7 @@ err_tx_ring_allocation:
> >  static int ixgbevf_set_interrupt_capability(struct ixgbevf_adapter *adapter)
> >  {
> >  	int err = 0;
> > -	int vector, v_budget;
> > +	int vector, v_budget, ncpu;
> >  
> >  	/*
> >  	 * It's easy to be greedy for MSI-X vectors, but it really
> > @@ -2022,8 +2022,9 @@ static int ixgbevf_set_interrupt_capability(struct ixgbevf_adapter *adapter)
> >  	 * than CPU's.  So let's be conservative and only ask for
> >  	 * (roughly) twice the number of vectors as there are CPU's.
> >  	 */
> > +	ncpu = min_t(int, num_online_cpus(), DEFAULT_MAX_NUM_RSS_QUEUES);
> >  	v_budget = min(adapter->num_rx_queues + adapter->num_tx_queues,
> > -		       (int)(num_online_cpus() * 2)) + NON_Q_VECTORS;
> > +		       ncpu * 2) + NON_Q_VECTORS;
> >  
> >  	/* A failure in MSI-X entry allocation isn't fatal, but it does
> >  	 * mean we disable MSI-X capabilities of the adapter. */
> This change is pointless on the ixgbevf driver.  The VF hardware can
> support at most 4 RSS queues.  As such num_rx_queues + num_tx_queues
> will never exceed 8 so you are essentially adding a necessary min(x,8).

It is pointless with the current value, but if someone will edit the
kernel source code and replace the 8 with a 2, it will become
meaningful. The compiler will optimize this part, and I think that for
completion, it is best to keep this reference so a future default number
change will not be missed.

Eilon
