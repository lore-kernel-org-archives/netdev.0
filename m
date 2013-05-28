From: "Keller, Jacob E" <jacob.e.keller@intel.com>
Subject: RE: [PATCH net-next 4/4] igb: enable auxiliary PHC functions for
 the i210.
Date: Tue, 28 May 2013 21:12:02 +0000
Message-ID: <02874ECE860811409154E81DA85FBB58564F1C88@ORSMSX104.amr.corp.intel.com>
References: <20130528162325.GD4678@netboy>
 <CDCA3AA1.1E8D4%matthew.vick@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
To: "Vick, Matthew" <matthew.vick@intel.com>,
	Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:31713 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756022Ab3E1VMF convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 May 2013 17:12:05 -0400
In-Reply-To: <CDCA3AA1.1E8D4%matthew.vick@intel.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: Vick, Matthew
> Sent: Tuesday, May 28, 2013 10:49 AM
> To: Richard Cochran
> Cc: netdev@vger.kernel.org; David Miller; e1000-
> devel@lists.sourceforge.net; Keller, Jacob E; Kirsher, Jeffrey T
> Subject: Re: [PATCH net-next 4/4] igb: enable auxiliary PHC functions for
> the i210.
> 
> On 5/28/13 9:23 AM, "Richard Cochran" <richardcochran@gmail.com>
> wrote:
> 
> >On Tue, May 28, 2013 at 03:58:07PM +0000, Vick, Matthew wrote:
> >> On 5/27/13 2:21 AM, "Richard Cochran" <richardcochran@gmail.com>
> wrote:
> >
> >> I would prefer it if we did a MAC check before these two TSICR
> checks,
> >> since we're making some assumptions about the hardware within the
> >> interrupt cases. At the very least, a comment that these are only
> >> applicable to I210/I211 would be nice.
> >
> >I can respin with a comment that the additional bits are i210 only. I
> >think this is better than adding more checks into ISR. Since we only
> >enable these bits for the i210, the checks would be redundant.
> 
> Personal preference would dictate a MAC check, but I'm alright with a
> comment. :)
>
> >> >diff --git a/drivers/net/ethernet/intel/igb/igb_ptp.c
> >> >b/drivers/net/ethernet/intel/igb/igb_ptp.c
> >> >index 5944de0..8cf4b8a 100644
> >> >--- a/drivers/net/ethernet/intel/igb/igb_ptp.c
> >> >+++ b/drivers/net/ethernet/intel/igb/igb_ptp.c
> >> >@@ -23,6 +23,15 @@
> >> >
> >> > #include "igb.h"
> >> >
> >> >+static int igb_input_sdp = 0;
> >> >+static int igb_output_sdp = 1;
> >> >+module_param(igb_input_sdp, int, 0444);
> >> >+module_param(igb_output_sdp, int, 0444);
> >> >+MODULE_PARM_DESC(igb_input_sdp,
> >> >+		 "The SDP used as an input, to time stamp external
> events");
> >> >+MODULE_PARM_DESC(igb_output_sdp,
> >> >+		 "The SDP used to output the programmable periodic
> signal");
> >> >+
> >>
> >> Is there any other mechanism we could use to control this? I would
> >>imagine
> >> not, but I know module parameters are generally frowned upon.
> >
> >This the way I handled it for the PHYTER, and I think it is the best
> >way from our three choices:
> >
> >1. kconfig option (inflexible)
> >2. module param
> >3. ethtool (can o'worms)
> 
> Ah, I didn't realize we had a precedent. Module param is fine with me,
> then. ethtool does seem like the right long-term solution, but I don't
> think that should gate your patchset if we already have a precedent for
> this functionality.

I think ethtool would be good, but what about using sysfs?

- Jake
