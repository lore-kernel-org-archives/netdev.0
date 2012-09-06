From: "Keller, Jacob E" <jacob.e.keller@intel.com>
Subject: RE: [net-next 13/13] igb: Store the MAC address in the name in the
 PTP struct.
Date: Thu, 6 Sep 2012 23:04:05 +0000
Message-ID: <02874ECE860811409154E81DA85FBB580785FA09@ORSMSX105.amr.corp.intel.com>
References: <1345715813-20757-1-git-send-email-jeffrey.t.kirsher@intel.com>
 <1345715813-20757-14-git-send-email-jeffrey.t.kirsher@intel.com>
 <20120823104554.GA2238@netboy.at.omicron.at>
 <1345757737.2579.22.camel@bwh-desktop.uk.solarflarecom.com>
 <20120824061956.GA2212@netboy.at.omicron.at>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"Vick, Matthew" <matthew.vick@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>,
	Stuart Hodgson <smhodgson@solarflare.com>
To: Richard Cochran <richardcochran@gmail.com>,
	Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:40501 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752946Ab2IFXEH convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Sep 2012 19:04:07 -0400
In-Reply-To: <20120824061956.GA2212@netboy.at.omicron.at>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.org]
> On Behalf Of Richard Cochran
> Sent: Thursday, August 23, 2012 11:20 PM
> To: Ben Hutchings
> Cc: Kirsher, Jeffrey T; davem@davemloft.net; Vick, Matthew;
> netdev@vger.kernel.org; gospo@redhat.com; sassmann@redhat.com; Stuart
> Hodgson
> Subject: Re: [net-next 13/13] igb: Store the MAC address in the name in
> the PTP struct.
> 
> In an ideal world, there is only one clock device per system, so the
> original concept was to use the driver name. The hardware designers have
> ignored or not understood the "one clock per system" model, and so,
> unfortunately, we have to deal with it.
> 
> A clock device can and should be connected to more than one network device
> (see gianfar, dp83640), and to give it a MAC address is misleading.
> 
> The ethtool solution works perfectly to go from interface->clock, which is
> all the information that a user space PTP stack needs.
> 
> I think for sysfs and the ioctl it is nicer to have the driver name, since
> it is associated with the clock and its capabilities.
> 
Correct. MAC address is misleading. However driver name for our parts is
misleading because each driver creates one clock per port. In either case, one
driver handling multiple cards would also have to create multiple ptp devices
and that is just as misleading.

The ethtool method is definitely preferred, and is the correct way to identify
the clock device correlation.

- Jake

> Thanks,
> Richard
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in the
> body of a message to majordomo@vger.kernel.org More majordomo info at
> http://vger.kernel.org/majordomo-info.html
