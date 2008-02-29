From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH] [NET 2.6.26]: Add per-connection option to set max TSO
	frame   size
Date: Fri, 29 Feb 2008 21:46:50 +0100
Message-ID: <20080229204650.GA2848@ami.dom.local>
References: <20080228183150.4431.81252.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, stephen.hemminger@vyatta.com,
	netdev@vger.kernel.org
To: PJ Waskiewicz <peter.p.waskiewicz.jr@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.186]:60971 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751831AbYB2Unl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Feb 2008 15:43:41 -0500
Received: by nf-out-0910.google.com with SMTP id g13so2438585nfb.21
        for <netdev@vger.kernel.org>; Fri, 29 Feb 2008 12:43:40 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20080228183150.4431.81252.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

PJ Waskiewicz wrote, On 02/28/2008 07:31 PM:
...
> This can be desirable to help tune the bursty nature of TSO on a
> per-adapter basis, where one may have 1 GbE and 10 GbE devices coexisting
> in a system, one running multiqueue and the other not, etc.
> 
> This can also be desirable for devices that cannot support full 64 KB
> TSO's, but still want to benefit from some level of segmentation
> offloading.
...
> +++ b/include/linux/netdevice.h
...
> +	/* for setting kernel sock attribute on TCP connection setup */
> +#define GSO_MAX_SIZE		65536
> +	u32			gso_max_size;

One more, maybe foolish, thrifty idea: do we really need such a
precision here? I don't know those devices, but maybe it would be
enough (for the beginning at least?) to use a few divisors e.g.:

gso_max_size = 65536 >> GSO_MAX_SIZE_SHIFT

Then it seems 3 or 4 bits should be enough for this, and BTW, it looks
like dev->features has 16 bits for various GSO flags, with "a lot" of
free space yet - unless I missed something?

Jarek P.
