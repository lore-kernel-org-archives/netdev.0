From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: Re: [net-next 11/13] igb: Make Tx budget for NAPI user adjustable
Date: Mon, 19 Sep 2011 15:27:32 -0700
Message-ID: <4E77C1D4.503@intel.com>
References: <4E776441.9090602@intel.com>	<1316448352.2764.27.camel@bwh-desktop>	<4E776E92.6090303@intel.com> <20110919.170033.344802441047363137.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: bhutchings@solarflare.com, jeffrey.t.kirsher@intel.com,
	netdev@vger.kernel.org, gospo@redhat.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:48597 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932429Ab1ISW0u (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 19 Sep 2011 18:26:50 -0400
In-Reply-To: <20110919.170033.344802441047363137.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/19/2011 02:00 PM, David Miller wrote:
> From: Alexander Duyck<alexander.h.duyck@intel.com>
> Date: Mon, 19 Sep 2011 09:32:18 -0700
>> The fact is ixgbe has been using this parameter this way for over 2
>> years now and the main goal of this patch was just to synchronize how
>> things work on igb and ixgbe.
>>
>> Our hardware doesn't have a mechanism for firing an interrupt after X
>> number of frames so instead we simply have modified things so that we
>> will only process X number of frames and then fire another
>> interrupt/poll if needed.  As such we aren't that far out of
>> compliance with the meaning of how this parameter is supposed to be
>> used.
> All I can say is this was a huge mistake you therefore need to revert
> the IXGBE change, these ethtool settings are not for changing NAPI or
> software interrupt behavior.
>
> And if you guys plan to be difficult on this and refuse to remove the
> IXGBE bits, I'm letting you guys know ahead of time that I'll do it
> for you.
>
> If the hardware can't support this facility, neither should these
> ethtool hooks, because the whole point is to avoid hardware interrupts
> from firing using these parameters.
>
> Propose new mechanisms to control NAPI behavior if you want.
I'll remove the ixgbe code if that is what you want.  It may be a month 
or so before I can get to it though since I am slammed with work so if 
you are in a hurry for it you might want to work with Jeff Kirsher to 
have the code removed.

As far as this current patch goes I honestly don't have the time to add 
or rewrite yet another ethtool interface so I will probably just see 
about dropping the ethtool portion of this patch and update the 
description in order to make it acceptable.

Thanks,

Alex
