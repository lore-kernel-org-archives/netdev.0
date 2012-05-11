From: "Keller, Jacob E" <jacob.e.keller@intel.com>
Subject: RE: [net-next 07/12] ixgbe: Enable timesync clock-out feature for
 PPS support on X540
Date: Fri, 11 May 2012 18:09:11 +0000
Message-ID: <02874ECE860811409154E81DA85FBB5807794955@ORSMSX105.amr.corp.intel.com>
References: <1336632413-19135-1-git-send-email-jeffrey.t.kirsher@intel.com>
 <1336632413-19135-8-git-send-email-jeffrey.t.kirsher@intel.com>
 <20120510141721.GC3392@localhost.localdomain>
 <02874ECE860811409154E81DA85FBB5807794253@ORSMSX105.amr.corp.intel.com>
 <20120511053605.GB2170@netboy.at.omicron.at>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:60721 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1422636Ab2EKSJO convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 May 2012 14:09:14 -0400
In-Reply-To: <20120511053605.GB2170@netboy.at.omicron.at>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: Richard Cochran [mailto:richardcochran@gmail.com]
> Sent: Thursday, May 10, 2012 10:36 PM
> To: Keller, Jacob E
> Cc: Kirsher, Jeffrey T; davem@davemloft.net; netdev@vger.kernel.org;
> gospo@redhat.com; sassmann@redhat.com
> Subject: Re: [net-next 07/12] ixgbe: Enable timesync clock-out feature for PPS
> support on X540
> 
> On Thu, May 10, 2012 at 09:54:52PM +0000, Keller, Jacob E wrote:
> > > Since this function is called in every interrupt, I would check this
> > > flag first thing.
> > >
> > Not sure what you mean? Check this before checking the other interrupts?
> > I can do that.
> 
> I only meant that, assuming that the other interrupt sources are much more
> frequent than the PPS, the normal case will be that the PPS flag is not set.
> 
> It would be more efficient (that is, shorter ISR code path in normal
> case) to check the flag first, perhaps like this.
> 
> ixgbe_intr()
> {
> 	...
> #ifdef CONFIG_IXGBE_PTP
> 	if (eicr & IXGBE_EICR_TIMESYNC)
> 		ixgbe_ptp_check_pps_event(adapter, eicr); #endif
> 	...
> }

Ok. This makes sense. :) Check the flag before checking the hardware type.

- Jake

> 
> Thanks,
> Richard
