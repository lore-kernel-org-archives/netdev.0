From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: Re: [net-next 4/7] ixgbe: Add function for testing status bits in
 Rx descriptor
Date: Mon, 13 Feb 2012 09:21:01 -0800
Message-ID: <4F39467D.9070409@intel.com>
References: <1328918904-11511-1-git-send-email-jeffrey.t.kirsher@intel.com>  <1328918904-11511-5-git-send-email-jeffrey.t.kirsher@intel.com> <1328987174.325.18.camel@deadeye>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, davem@davemloft.net,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:35411 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755411Ab2BMRVD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 13 Feb 2012 12:21:03 -0500
In-Reply-To: <1328987174.325.18.camel@deadeye>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/11/2012 11:06 AM, Ben Hutchings wrote:
> On Fri, 2012-02-10 at 16:08 -0800, Jeff Kirsher wrote:
>> From: Alexander Duyck <alexander.h.duyck@intel.com>
>>
>> This change adds a small function for testing Rx status bits in the
>> descriptor.  The advantage to this is that we can avoid unnecessary
>> byte swaps on big endian systems.
> [...]
>> +	/* unmap the sg list when FCPRSP is received */
>> +	case __constant_cpu_to_le32(IXGBE_RXDADV_STAT_FCSTAT_FCPRSP):
> [...]
>
> cpu_to_le32() works as a compile-time constant when given a constant
> argument.  You shouldn't need this ugly __constant_ prefix.
>
> Ben.
>

If that is the case then what is the point of even having the
__constant_ prefixed version of these macros anyway?  I ask because I
know we have had people submit patches in the past replacing htons calls
with __constant_htons and the like and nobody has ever spoken up before
to indicate that these were unnecessary.

Why don't you submit patches to get rid of these calls from the kernel
all together and just replace references to them with their non-prefixed
counterparts?  Then you wouldn't have to worry about changes like this
being submitted in the future.

Alex
