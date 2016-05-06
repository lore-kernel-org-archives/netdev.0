From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH net v3 2/2] udp_offload: Set encapsulation before inner completes.
Date: Fri, 6 May 2016 13:20:57 -0700
Message-ID: <CALx6S34AZ6t5t5VqodMFB4PVVYf4w+4SA+a6frsySOiJ9qVCRA@mail.gmail.com>
References: <1462317021-7236-1-git-send-email-jarno@ovn.org>
	<1462317021-7236-2-git-send-email-jarno@ovn.org>
	<20160506.153412.1756777490005831525.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jarno Rajahalme <jarno@ovn.org>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Alexander Duyck <alexander.duyck@gmail.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f181.google.com ([209.85.223.181]:35884 "EHLO
	mail-io0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758671AbcEFUU6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 May 2016 16:20:58 -0400
Received: by mail-io0-f181.google.com with SMTP id u185so143988345iod.3
        for <netdev@vger.kernel.org>; Fri, 06 May 2016 13:20:57 -0700 (PDT)
In-Reply-To: <20160506.153412.1756777490005831525.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 6, 2016 at 12:34 PM, David Miller <davem@davemloft.net> wrote:
> From: Jarno Rajahalme <jarno@ovn.org>
> Date: Tue,  3 May 2016 16:10:21 -0700
>
>> UDP tunnel segmentation code relies on the inner offsets being set for
>> an UDP tunnel GSO packet, but the inner *_complete() functions will
>> set the inner offsets only if 'encapsulation' is set before calling
>> them.  Currently, udp_gro_complete() sets 'encapsulation' only after
>> the inner *_complete() functions are done.  This causes the inner
>> offsets having invalid values after udp_gro_complete() returns, which
>> in turn will make it impossible to properly segment the packet in case
>> it needs to be forwarded, which would be visible to the user either as
>> invalid packets being sent or as packet loss.
>>
>> This patch fixes this by setting skb's 'encapsulation' in
>> udp_gro_complete() before calling into the inner complete functions,
>> and by making each possible UDP tunnel gro_complete() callback set the
>> inner_mac_header to the beginning of the tunnel payload.
>>
>> Signed-off-by: Jarno Rajahalme <jarno@ovn.org>
>> ---
>> v3: Added setting inner_mac_header from all possible callbacks to cover
>>     cases where there is no inner mac header.
>
> Alex and Tom, can you please review this new version since you guys had
> so much feedback for v2?
>

I'm okay with the patch.Clarifying exactly what skb->encaspulation
means is future work.

> THanks.
