From: "Allan, Bruce W" <bruce.w.allan@intel.com>
Subject: RE: [net-next 04/14] e1000e: add support for IEEE-1588 PTP
Date: Fri, 18 Jan 2013 01:13:22 +0000
Message-ID: <804857E1F29AAC47BF68C404FC60A1843ABB7EF9@ORSMSX102.amr.corp.intel.com>
References: <1358422519-20981-1-git-send-email-jeffrey.t.kirsher@intel.com>
 <1358422519-20981-5-git-send-email-jeffrey.t.kirsher@intel.com>
 <20130117153535.GA2937@netboy.at.omicron.at>
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
Received: from mga11.intel.com ([192.55.52.93]:8107 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753123Ab3ARBNX convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Jan 2013 20:13:23 -0500
In-Reply-To: <20130117153535.GA2937@netboy.at.omicron.at>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: Richard Cochran [mailto:richardcochran@gmail.com]
> Sent: Thursday, January 17, 2013 7:36 AM
> To: Kirsher, Jeffrey T
> Cc: davem@davemloft.net; Allan, Bruce W; netdev@vger.kernel.org;
> gospo@redhat.com; sassmann@redhat.com
> Subject: Re: [net-next 04/14] e1000e: add support for IEEE-1588 PTP
> 
> On Thu, Jan 17, 2013 at 03:35:09AM -0800, Jeff Kirsher wrote:
> 
> > +static struct ptp_clock_info e1000e_ptp_clock_info = {
> > +	.owner		= THIS_MODULE,
> 
> small nit: better to use a static string for .name here than ...
> 
> > +	.n_alarm	= 0,
> > +	.n_ext_ts	= 0,
> > +	.n_per_out	= 0,
> > +	.pps		= 0,
> > +	.adjfreq	= e1000e_phc_adjfreq,
> > +	.adjtime	= e1000e_phc_adjtime,
> > +	.gettime	= e1000e_phc_gettime,
> > +	.settime	= e1000e_phc_settime,
> > +	.enable		= e1000e_phc_enable,
> > +};
> > +
> > +/**
> > + * e1000e_ptp_init - initialize PTP for devices which support it
> > + * @adapter: board private structure
> > + *
> > + * This function performs the required steps for enabling PTP support.
> > + * If PTP support has already been loaded it simply calls the cyclecounter
> > + * init routine and exits.
> > + **/
> > +void e1000e_ptp_init(struct e1000_adapter *adapter)
> > +{
> > +	struct e1000_hw *hw = &adapter->hw;
> > +
> > +	adapter->ptp_clock = NULL;
> > +
> > +	if (!(adapter->flags & FLAG_HAS_HW_TIMESTAMP))
> > +		return;
> > +
> > +	adapter->ptp_clock_info = e1000e_ptp_clock_info;
> > +
> > +	snprintf(adapter->ptp_clock_info.name,
> > +		 sizeof(adapter->ptp_clock_info.name), "%pm",
> > +		 adapter->netdev->perm_addr);
> 
> ... putting any kind of address here. After some back and forth,
> discussing what the 'name' field should be, we decided on
> 
>  * @name:      A short "friendly name" to identify the clock and to
>  *             help distinguish PHY based devices from MAC based ones.
>  *             The string is not meant to be a unique id.
> 
> and most other drivers put the name of the driver here.
> 
> Other than that, this new driver looks good to me. I'll try it out
> soon.
> 
> Acked-by: Richard Cochran <richardcochran@gmail.com>

Thanks for the review Richard.
