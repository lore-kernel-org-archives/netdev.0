From: "Keller, Jacob E" <jacob.e.keller@intel.com>
Subject: RE: [net-next 07/12] ixgbe: Enable timesync clock-out feature for
 PPS support on X540
Date: Thu, 10 May 2012 21:54:52 +0000
Message-ID: <02874ECE860811409154E81DA85FBB5807794253@ORSMSX105.amr.corp.intel.com>
References: <1336632413-19135-1-git-send-email-jeffrey.t.kirsher@intel.com>
 <1336632413-19135-8-git-send-email-jeffrey.t.kirsher@intel.com>
 <20120510141721.GC3392@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>
To: Richard Cochran <richardcochran@gmail.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:13970 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761588Ab2EJVyy convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 May 2012 17:54:54 -0400
In-Reply-To: <20120510141721.GC3392@localhost.localdomain>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



> -----Original Message-----
> From: Richard Cochran [mailto:richardcochran@gmail.com]
> Sent: Thursday, May 10, 2012 7:17 AM
> To: Kirsher, Jeffrey T
> Cc: davem@davemloft.net; Keller, Jacob E; netdev@vger.kernel.org;
> gospo@redhat.com; sassmann@redhat.com
> Subject: Re: [net-next 07/12] ixgbe: Enable timesync clock-out feature for PPS
> support on X540
> 
> On Wed, May 09, 2012 at 11:46:48PM -0700, Jeff Kirsher wrote:
> > From: Jacob E Keller <jacob.e.keller@intel.com>
> >
> > This patch enables the PPS system in the PHC framework, by enabling
> > the clock-out feature on the X540 device. Causes the SDP0 to be set as
> > a 1Hz clock. Also configures the timesync interrupt cause in order to
> > report each pulse to the PPS via the PHC framework, which can be used
> > for general system clock synchronization. (This allows a stable method
> > for tuning the general system time via the on-board SYSTIM register
> > based clock.)
> 
> Glad to see the PPS output and internal PPS support.
> 
> > diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
> > b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
> > index 9a83c40..1ad6e2a 100644
> > --- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
> > +++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
> 
> ...
> 
> >  /**
> > + * ixgbe_ptp_check_pps_event
> > + * @adapter - the private adapter structure
> > + * @eicr - the interrupt cause register value
> > + *
> > + * This function is called by the interrupt routine when checking for
> > + * interrupts. It will check and handle a pps event.
> > + */
> > +void ixgbe_ptp_check_pps_event(struct ixgbe_adapter *adapter, u32
> > +eicr) {
> > +	struct ixgbe_hw *hw = &adapter->hw;
> > +	struct ptp_clock_event event;
> > +
> > +	event.type = PTP_CLOCK_PPS;
> > +
> > +	/* Make sure ptp clock is valid, and PPS event enabled */
> > +	if (!adapter->ptp_clock ||
> > +	    !(adapter->flags2 & IXGBE_FLAG2_PTP_PPS_ENABLED))
> > +		return;
> > +
> > +	switch (hw->mac.type) {
> > +	case ixgbe_mac_X540:
> > +		if (eicr & IXGBE_EICR_TIMESYNC)
> 
> Since this function is called in every interrupt, I would check this flag
> first thing.
> 
Not sure what you mean? Check this before checking the other interrupts?
I can do that.

> > +			ptp_clock_event(adapter->ptp_clock, &event);
> > +		break;
> > +	default:
> > +		break;
> > +	}
> > +}
> 
> Thanks,
> Richard
