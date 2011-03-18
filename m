From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: Re: [PATCH net-2.6] ethtool: Compat handling for struct ethtool_rxnfc
Date: Fri, 18 Mar 2011 13:01:58 -0700
Message-ID: <4D83BA36.8020301@intel.com>
References: <1300383272.2569.13.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Santwona Behera <santwona.behera@sun.com>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:20456 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753937Ab1CRUB7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 Mar 2011 16:01:59 -0400
In-Reply-To: <1300383272.2569.13.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 3/17/2011 10:34 AM, Ben Hutchings wrote:
> This structure was accidentally defined such that its layout can
> differ between 32-bit and 64-bit processes.  Add compat structure
> definitions and an ioctl wrapper function.
>
> Signed-off-by: Ben Hutchings<bhutchings@solarflare.com>
> Cc: stable@kernel.org [2.6.30+]
> ---
> David,
>
> I still haven't received any response on whether the ETHTOOL_GRXCLSRLALL
> wrapping works with a real driver, but perhaps you could test it against
> niu?  I think sparc32 and sparc64 have the same alignment for u64 so
> this wrapper isn't strictly necessary, but it would still be used.  (Or
> we can arrange to disable the conversion when compat_ethtool_rxnfc is
> equivalent to ethtool_rxnfc.)
>
> Ben.

I've done a bit of testing this morning and verified GRXRINGS, 
GRCLSRLCNT, GRXCLSRULE, SRXCLSRLDEL, and SRXCLSRLINS all seem to be 
working for 32bit and 64bit ethtool user space on a x86_64 kernel with 
the patch.  I also verified the original issue was present by running 
32bit ethtool on a x86_64 kernel without the patch applied.

In order to support flow extensions there will end up being a couple of 
minor changes needed to the patch but I will just make sure to add them 
when flow extensions are added.

Thanks,

Alex

Acked-by: Alexander Duyck <alexander.h.duyck@intel.com>
