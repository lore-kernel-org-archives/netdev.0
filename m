From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: Re: [net-next 38/40] ixgbe: Update feature flags so that LRO and
 Ntuple are restricted
Date: Tue, 07 Jun 2011 15:32:24 -0700
Message-ID: <4DEEA6F8.3050901@intel.com>
References: <1307449995-9458-1-git-send-email-jeffrey.t.kirsher@intel.com>	 <1307449995-9458-39-git-send-email-jeffrey.t.kirsher@intel.com> <1307452559.2908.15.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, davem@davemloft.net,
	netdev@vger.kernel.org, gospo@redhat.com
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:1307 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756931Ab1FGWdH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 7 Jun 2011 18:33:07 -0400
In-Reply-To: <1307452559.2908.15.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/07/2011 06:15 AM, Ben Hutchings wrote:
> On Tue, 2011-06-07 at 05:33 -0700, Jeff Kirsher wrote:
>> From: Alexander Duyck<alexander.h.duyck@intel.com>
>>
>> This change makes it so that LRO and Ntuple flags are correctly restricted
>> to only devices that support those features.  Currently we weren't
>> enforcing any of those restrictions and as such it was possible to do
>> things such as enable LRO without it actually being supported on the
>> hardware.
>>
>> This change also makes a slight modification to the code that assumes the
>> ETH_FLAG_RXVLAN is the same as the netdev flag. I corrected it by just adding
>> a !! to cast the result of the flag&  to a bool in order to guarantee the two
>> checks are compared as boolean values.
> [...]
>
> You could BUILD_BUG_ON(ETH_FLAG_RXVLAN != NETIF_F_HW_VLAN_RX).
>
> Or implement the new features interface like every other driver...
>
> Ben.

I hadn't looked at what was going on outside of the Intel drivers and 
didn't realize that the get/set_flags calls had been deprecated.

For now I would appreciate it if the existing patch does get accepted, 
but I will see what can be done to move things over to using the new 
features interface.

Thanks,

Alex
