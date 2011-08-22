From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: Re: [net-next 03/10] ixgbe: Drop the TX work limit and instead just
 leave it to budget
Date: Mon, 22 Aug 2011 10:29:51 -0700
Message-ID: <4E52920F.7060603@intel.com>
References: <1313911761-11709-1-git-send-email-jeffrey.t.kirsher@intel.com>	 <1313911761-11709-4-git-send-email-jeffrey.t.kirsher@intel.com>	 <1313935304.3142.22.camel@deadeye>  <4E528437.5060302@intel.com> <1314031612.2803.7.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, davem@davemloft.net,
	netdev@vger.kernel.org, gospo@redhat.com
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:8223 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751592Ab1HVRcp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 22 Aug 2011 13:32:45 -0400
In-Reply-To: <1314031612.2803.7.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/22/2011 09:46 AM, Ben Hutchings wrote:
> On Mon, 2011-08-22 at 09:30 -0700, Alexander Duyck wrote:
>> On 08/21/2011 07:01 AM, Ben Hutchings wrote:
>>> On Sun, 2011-08-21 at 00:29 -0700, Jeff Kirsher wrote:
>>>> From: Alexander Duyck<alexander.h.duyck@intel.com>
>>>>
>>>> This change makes it so that the TX work limit is now obsolete.  Instead of
>>>> using it we can instead rely on the NAPI budget for the number of packets
>>>> we should clean per interrupt.  The advantage to this approach is that it
>>>> results in a much more balanced work flow since the same number of RX and
>>>> TX packets should be cleaned per interrupts.
>>> [...]
>>>
>>> This seems kind of sensible, but it's not how Dave has been recommending
>>> people to account for TX work in NAPI.
>>>
>>> Ben.
>>>
>> I wasn't aware there was a recommended approach.  Could you tell me more
>> about it?
> If a whole TX ring is cleaned then consider the budget spent; otherwise
> don't count it.
>
> Ben.

The only problem I was seeing with that was that in certain cases it 
seemed like the TX cleanup could consume enough CPU time to cause pretty 
significant delays in processing the RX cleanup.  This in turn was 
causing single queue bi-directional routing tests to come out pretty 
unbalanced since what seemed to happen is that one CPUs RX work would 
overwhelm the other CPU with the TX processing resulting in an 
unbalanced flow that was something like a 60/40 split between the 
upstream and downstream throughput.

Thanks,

Alex
