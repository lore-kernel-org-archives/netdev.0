From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [PATCH net v3 2/2] udp_offload: Set encapsulation before inner completes.
Date: Fri, 6 May 2016 12:52:39 -0700
Message-ID: <CAKgT0UdC=rPvV24ftW3w1vLhmeq=SENLJSNNnQDsMQNNLDmHJA@mail.gmail.com>
References: <1462317021-7236-1-git-send-email-jarno@ovn.org>
	<1462317021-7236-2-git-send-email-jarno@ovn.org>
	<20160506.153412.1756777490005831525.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jarno Rajahalme <jarno@ovn.org>, Netdev <netdev@vger.kernel.org>,
	Tom Herbert <tom@herbertland.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f179.google.com ([209.85.213.179]:37553 "EHLO
	mail-ig0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758322AbcEFTwk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 May 2016 15:52:40 -0400
Received: by mail-ig0-f179.google.com with SMTP id s8so49499572ign.0
        for <netdev@vger.kernel.org>; Fri, 06 May 2016 12:52:40 -0700 (PDT)
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
> THanks.

I had reviewed it a day or so ago.  It did address the issues I saw
with the original patch, and from what I can tell it is fixing the
original issue reported.

Reviewed-by: Alexander Duyck <aduyck@mirantis.com>
