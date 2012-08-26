From: "Keller, Jacob E" <jacob.e.keller@intel.com>
Subject: RE: [net-next 10/13] igb: Tidy up wrapping for CONFIG_IGB_PTP.
Date: Sun, 26 Aug 2012 01:33:42 +0000
Message-ID: <02874ECE860811409154E81DA85FBB58078591DF@ORSMSX105.amr.corp.intel.com>
References: <1345715813-20757-1-git-send-email-jeffrey.t.kirsher@intel.com>
 <1345715813-20757-11-git-send-email-jeffrey.t.kirsher@intel.com>
 <20120823110357.GB2238@netboy.at.omicron.at>
 <06DFBC1E25D8024DB214DC7F41A3CD34488DD039@ORSMSX101.amr.corp.intel.com>
 <20120823172950.GA2192@netboy.at.omicron.at>
 <02874ECE860811409154E81DA85FBB5807857EFE@ORSMSX105.amr.corp.intel.com>
 <06DFBC1E25D8024DB214DC7F41A3CD34488DD35B@ORSMSX101.amr.corp.intel.com>
 <20120824101053.GA6038@netboy.at.omicron.at>
 <1345827088.2694.11.camel@bwh-desktop.uk.solarflarecom.com>
 <02874ECE860811409154E81DA85FBB5807858A31@ORSMSX105.amr.corp.intel.com>
 <20120825062013.GB2233@netboy.at.omicron.at>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	"Vick, Matthew" <matthew.vick@intel.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:48053 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752215Ab2HZBdo convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 25 Aug 2012 21:33:44 -0400
In-Reply-To: <20120825062013.GB2233@netboy.at.omicron.at>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



> -----Original Message-----
> From: Richard Cochran [mailto:richardcochran@gmail.com]
> Sent: Friday, August 24, 2012 11:20 PM
> To: Keller, Jacob E
> Cc: Ben Hutchings; Vick, Matthew; Kirsher, Jeffrey T; davem@davemloft.net;
> netdev@vger.kernel.org; gospo@redhat.com; sassmann@redhat.com
> Subject: Re: [net-next 10/13] igb: Tidy up wrapping for CONFIG_IGB_PTP.
> 
> On Fri, Aug 24, 2012 at 07:38:38PM +0000, Keller, Jacob E wrote:
> 
> > The IGP_PTP is necessary otherwise you have to do something like #if
> > defined(CONFIG_PTP_1588_CLOCK), or #ifdef CONFIG_PTP_1588_CLOCK \
> > #ifdef CONFIG_PTP_1588_CLOCK_MODULE
> 
> Yes, but maybe use IGP_PTP as Ben described?

That's exactly what I was saying :) That's the reason why IGP_PTP is necessary.

> 
> > The main reason that I wouldn't want to un-wrap the timestamping is
> > because the hwtstamp ioctl is somewhat problematic because it is
> > almost all ptp only. Also, some of the parts for igb driver don't
> > support timestamp all, they only support ptp only packets, and this
> > would be a lot more confusing since I would say still only allow that
> > if ptp is on.. (since those values are useless except with the PHC
> > clock)
> 
> I keep trying to explain that receive time stamping (HWTSTAMP_FILTER_ALL)
> is useful all by itself. It has nothing to do with PTP, and the 82580 can
> do this with very little ** overhead.
> 
> I myself have used this feature when debugging and profiling quasi real
> time Ethernet protocols like EtherCAT and IEC61850-9-2. The other drivers
> that offer this (gianfar and vxge) do so without any CONFIG conditionals.
> 
> IMHO, the Rx time stamping feature should always be available. It is
> really not much different than the vlan feature.

IMO it should be but only for parts with HWTSTAMP_FILTER_ALL, and only for that mode (other modes should be ignored) because timestamping only PTP packets is a PTP feature, so this change should still disable other modes if they exist.

> 
> Thanks,
> Richard
> 
> ** Both igb_rx_hwtstamp and igb_tx_hwtstamp only add a single test
>    when time stamping is not enabled.
