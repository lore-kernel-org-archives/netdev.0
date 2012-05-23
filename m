From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: Re: TCPBacklogDrops during aggressive bursts of traffic
Date: Wed, 23 May 2012 10:10:36 -0700
Message-ID: <4FBD1A0C.4070606@intel.com>
References: <1337092718.1689.45.camel@kjm-desktop.uk.level5networks.com>  <1337099641.8512.1102.camel@edumazet-glaptop>  <1337100454.2544.25.camel@bwh-desktop.uk.solarflarecom.com>  <1337101280.8512.1108.camel@edumazet-glaptop>  <1337272292.1681.16.camel@kjm-desktop.uk.level5networks.com>  <1337272654.3403.20.camel@edumazet-glaptop>  <1337674831.1698.7.camel@kjm-desktop.uk.level5networks.com>  <1337678759.3361.147.camel@edumazet-glaptop>  <1337679045.3361.154.camel@edumazet-glaptop>  <1337699379.1698.30.camel@kjm-desktop.uk.level5networks.com>  <1337703170.3361.217.camel@edumazet-glaptop>  <1337704382.1698.53.camel@kjm-desktop.uk.level5networks.com>  <1337705135.3361.226.camel@edumazet-glaptop>  <1337720076.3361.667.camel@edumazet-glaptop>  <1337766246.3361.2447.camel@edumazet-glaptop>  <1
 337774978.3361.2744.camel@edumazet-glaptop>  <4FBD0A85.4040407@intel.com>  <1337789530.3361.2992.camel@edumazet-glaptop> <1337791189.3361.3029.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Kieran Mansley <kmansley@solarflare.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:9755 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751145Ab2EWRKg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 May 2012 13:10:36 -0400
In-Reply-To: <1337791189.3361.3029.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/23/2012 09:39 AM, Eric Dumazet wrote:
> On Wed, 2012-05-23 at 18:12 +0200, Eric Dumazet wrote:
>
>> With current driver, a MTU=1500 frame uses :
>>
>> sk_buff (256 bytes)
>> skb->head : 1024 bytes  (or more exaclty now : 512 + 384)
> By the way, NET_SKB_PAD adds 64 bytes so its 64 + 512 + 384 = 960
Actually pahole seems to be indicating to me the size of skb_shared_info
is 320, unless something has changed in the last few days.

When I get a chance I will try to remember to reduce the ixgbe header
size to 256 which should also help.  The only reason it is set to 512
was to deal with the fact that the old alloc_skb code wasn't aligning
the shared info with the end of whatever size was allocated and so the
512 was an approximation to make better use of the 1K slab allocation
back when we still were using hardware packet split.  That should help
to improve the page utilization for the headers since that would
increase the uses of a page from 4 to 6 for the skb head frag, and it
would drop truesize by another 256 bytes.

Thanks,

Alex
