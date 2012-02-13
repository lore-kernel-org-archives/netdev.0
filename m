From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [net-next 4/7] ixgbe: Add function for testing status bits in
 Rx descriptor
Date: Mon, 13 Feb 2012 17:37:46 +0000
Message-ID: <1329154666.2697.16.camel@bwh-desktop>
References: <1328918904-11511-1-git-send-email-jeffrey.t.kirsher@intel.com>
	  <1328918904-11511-5-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1328987174.325.18.camel@deadeye> <4F39467D.9070409@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, <davem@davemloft.net>,
	<netdev@vger.kernel.org>, <gospo@redhat.com>, <sassmann@redhat.com>
To: Alexander Duyck <alexander.h.duyck@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:8224 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1755578Ab2BMRhv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Feb 2012 12:37:51 -0500
In-Reply-To: <4F39467D.9070409@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2012-02-13 at 09:21 -0800, Alexander Duyck wrote:
> On 02/11/2012 11:06 AM, Ben Hutchings wrote:
> > On Fri, 2012-02-10 at 16:08 -0800, Jeff Kirsher wrote:
> >> From: Alexander Duyck <alexander.h.duyck@intel.com>
> >>
> >> This change adds a small function for testing Rx status bits in the
> >> descriptor.  The advantage to this is that we can avoid unnecessary
> >> byte swaps on big endian systems.
> > [...]
> >> +	/* unmap the sg list when FCPRSP is received */
> >> +	case __constant_cpu_to_le32(IXGBE_RXDADV_STAT_FCSTAT_FCPRSP):
> > [...]
> >
> > cpu_to_le32() works as a compile-time constant when given a constant
> > argument.  You shouldn't need this ugly __constant_ prefix.
> >
> > Ben.
> >
> 
> If that is the case then what is the point of even having the
> __constant_ prefixed version of these macros anyway?  I ask because I
> know we have had people submit patches in the past replacing htons calls
> with __constant_htons and the like and nobody has ever spoken up before
> to indicate that these were unnecessary.
[...]

Probably for backward-compatibility, as this wasn't true before Linux
2.6.22.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
