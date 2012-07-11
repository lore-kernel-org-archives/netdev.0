From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: Re: [RFC PATCH 07/10] ixgbe: Add function for setting XPS queue mapping
Date: Wed, 11 Jul 2012 14:12:57 -0700
Message-ID: <4FFDEC59.9040303@intel.com>
References: <20120630000652.29939.11108.stgit@gitlad.jf.intel.com>  <20120630001649.29939.725.stgit@gitlad.jf.intel.com> <1342030507.2613.46.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	jeffrey.t.kirsher@intel.com, edumazet@google.com,
	therbert@google.com, alexander.duyck@gmail.com
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:37474 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755263Ab2GKVM6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Jul 2012 17:12:58 -0400
In-Reply-To: <1342030507.2613.46.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/11/2012 11:15 AM, Ben Hutchings wrote:
> On Fri, 2012-06-29 at 17:16 -0700, Alexander Duyck wrote:
>> This change adds support for ixgbe to configure the XPS queue mapping on
>> load.  The result of this change is that on open we will now be resetting
>> the number of Tx queues, and then setting the default configuration for XPS
>> based on if ATR is enabled or disabled.
> [...]
>
> I didn't see where you're resetting the number of TX queues; was that
> actually added in an earlier patch?
>
> It seems strange to be resetting XPS configuration on open; normally net
> device configuration persists as long as the device is registered.
> Maybe only do this if the number of TX queues has to change?
>
> Ben.
>
Actually I am working on top of a set of patches for ixgbe that haven't
been submitted upstream.  In one of those patches I moved our call to
netif_set_real_num_tx_queues into ixgbe_open.  The call is only one or
two lines above the call I make to ixgbe_set_xps_mapping.

I will see what I can do about resetting the settings only when we
change the number of queues.

Thanks,

Alex
