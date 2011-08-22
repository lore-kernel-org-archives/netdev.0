From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: Re: [net-next 03/10] ixgbe: Drop the TX work limit and instead just
 leave it to budget
Date: Mon, 22 Aug 2011 09:30:47 -0700
Message-ID: <4E528437.5060302@intel.com>
References: <1313911761-11709-1-git-send-email-jeffrey.t.kirsher@intel.com>	 <1313911761-11709-4-git-send-email-jeffrey.t.kirsher@intel.com> <1313935304.3142.22.camel@deadeye>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, davem@davemloft.net,
	netdev@vger.kernel.org, gospo@redhat.com
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:53694 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751432Ab1HVQdo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 22 Aug 2011 12:33:44 -0400
In-Reply-To: <1313935304.3142.22.camel@deadeye>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/21/2011 07:01 AM, Ben Hutchings wrote:
> On Sun, 2011-08-21 at 00:29 -0700, Jeff Kirsher wrote:
>> From: Alexander Duyck<alexander.h.duyck@intel.com>
>>
>> This change makes it so that the TX work limit is now obsolete.  Instead of
>> using it we can instead rely on the NAPI budget for the number of packets
>> we should clean per interrupt.  The advantage to this approach is that it
>> results in a much more balanced work flow since the same number of RX and
>> TX packets should be cleaned per interrupts.
> [...]
>
> This seems kind of sensible, but it's not how Dave has been recommending
> people to account for TX work in NAPI.
>
> Ben.
>
I wasn't aware there was a recommended approach.  Could you tell me more 
about it?

As I stated in the patch description this approach works very well for 
me, especially in routing workloads since it typically keeps the TX 
clean-up in polling as long as the RX is in polling.

Thanks,

Alex
