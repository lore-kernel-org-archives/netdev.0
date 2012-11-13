From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: Re: [net-next 01/11] ixgbe: Do not use DCA to prefetch the entire
 packet into the cache
Date: Tue, 13 Nov 2012 09:41:38 -0800
Message-ID: <50A28652.6020505@intel.com>
References: <1352815405-751-1-git-send-email-jeffrey.t.kirsher@intel.com>  <1352815405-751-2-git-send-email-jeffrey.t.kirsher@intel.com> <1352816011.6185.33.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, davem@davemloft.net,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:63447 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752108Ab2KMRlj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Nov 2012 12:41:39 -0500
In-Reply-To: <1352816011.6185.33.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/13/2012 06:13 AM, Eric Dumazet wrote:
> On Tue, 2012-11-13 at 06:03 -0800, Jeff Kirsher wrote:
>> From: Alexander Duyck <alexander.h.duyck@intel.com>
>>
>> The way the code was previously written it was causing DCA to prefetch the
>> entire packet into the cache when it was enabled.  That is excessive as we
>> only really need the headers.
>>
>> We are now prefetching the headers via software so doing this from DCA would
>> be redundant anyway.  So clear the bit that was causing us to prefetch the
>> packet data and instead only use DCA for the descriptor rings.
>>
>> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
>> Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
>> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
>> ---
> Excellent !
>
> My own ixgbe cards are moving so I cant test this, do you guys have some
> numbers to share ?
>
> Thanks

In my tests I saw no real change because of the DCA changes.  I kind of
suspected that would be the case as mentioned in the patch the prefetch
and DCA were both doing the same thing so by dropping the extra DCA
prefetch I am just polluting the case less.

I have a similar set of changes for the ixgbe transmit path that are
similar to the changes I made to igb in this patch set.  Those are a bit
more interesting as they actually decreased the ixgbe_xmit_frame_ring
function overhead for some of my tests by something like 15%.

Thanks,

Alex
