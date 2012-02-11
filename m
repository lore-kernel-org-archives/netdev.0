From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [net-next 4/7] ixgbe: Add function for testing status bits in
 Rx descriptor
Date: Sat, 11 Feb 2012 19:06:14 +0000
Message-ID: <1328987174.325.18.camel@deadeye>
References: <1328918904-11511-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1328918904-11511-5-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	<netdev@vger.kernel.org>, <gospo@redhat.com>, <sassmann@redhat.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:10643 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751335Ab2BKTGK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 Feb 2012 14:06:10 -0500
In-Reply-To: <1328918904-11511-5-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2012-02-10 at 16:08 -0800, Jeff Kirsher wrote:
> From: Alexander Duyck <alexander.h.duyck@intel.com>
> 
> This change adds a small function for testing Rx status bits in the
> descriptor.  The advantage to this is that we can avoid unnecessary
> byte swaps on big endian systems.
[...]
> +	/* unmap the sg list when FCPRSP is received */
> +	case __constant_cpu_to_le32(IXGBE_RXDADV_STAT_FCSTAT_FCPRSP):
[...]

cpu_to_le32() works as a compile-time constant when given a constant
argument.  You shouldn't need this ugly __constant_ prefix.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
