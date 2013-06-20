From: "Nelson, Shannon" <shannon.nelson@intel.com>
Subject: RE: [net-next 1/8] i40e: main driver core
Date: Thu, 20 Jun 2013 20:50:53 +0000
Message-ID: <FC41C24E35F18A40888AACA1A36F3E4168533F7C@FMSMSX102.amr.corp.intel.com>
References: <1371182122-26629-1-git-send-email-jeffrey.t.kirsher@intel.com>
	<1371182122-26629-2-git-send-email-jeffrey.t.kirsher@intel.com>
 <20130619115542.767eaee4@samsung-9>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>,
	"Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>
To: Stephen Hemminger <stephen@networkplumber.org>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:53494 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965660Ab3FTUu4 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Jun 2013 16:50:56 -0400
In-Reply-To: <20130619115542.767eaee4@samsung-9>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: Stephen Hemminger [mailto:stephen@networkplumber.org]
> Sent: Wednesday, June 19, 2013 11:56 AM
> 
> On Thu, 13 Jun 2013 20:55:15 -0700
> Jeff Kirsher <jeffrey.t.kirsher@intel.com> wrote:
> 
> > +
> > +char i40e_driver_name[] = "i40e";
> 
> Obviously const

Yep.
 
> +/* Helper macros for reading the stats registers
> + *
> + * Since the device stats are not reset at PFReset, they likely will
> not
> + * be zeroed when the driver starts.  We'll save the first values read
> + * and use them as offsets to be subtracted from the raw values in
> order
> + * to report stats that count from zero.
> + */
> +#define I40E_STAT_UPDATE48(hireg, loreg, offset_loaded, offset, stat)
> \
> +do {
> \
> +	u64 new_data;                                                     \
> +	new_data = rd64(hw, (loreg));                                     \
> +	if (!(offset_loaded))                                             \
> +		(offset) = new_data;                                      \
> +	if (likely(new_data >= (offset)))                                 \
> +		(stat) = new_data - (offset);                             \
> +	else                                                              \
> +		(stat) = (new_data + ((u64)1 << 48)) - (offset);          \
> +	(stat) &= 0xFFFFFFFFFFFFULL;                                      \
> +} while (0)
> 
> Macro's suck, this could just as well be a function
> or maybe a macro that calls function (and go ahead and do string
> manipulation)

Yep - thanks.

sln
