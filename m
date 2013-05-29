From: Olof Johansson <olof@lixom.net>
Subject: Re: [PATCH net-next v5 1/2] net: Use 16bits for *_headers fields of
 struct skbuff
Date: Wed, 29 May 2013 16:02:12 -0700
Message-ID: <CAOesGMjuOaSr6vG+bPQGAdNKa4yeAOFLA+eyBHS+rDvevQASHQ@mail.gmail.com>
References: <1369378295-17779-1-git-send-email-horms@verge.net.au>
	<1369378295-17779-2-git-send-email-horms@verge.net.au>
	<CAOesGMg2-CgJeqFM7K1QBAhG+xOc33t0vV1xR1J_4-iJJ58r8A@mail.gmail.com>
	<CAOesGMimq2agyihTHkrGox26QVX_n9MZkcU7XSMWb941-kfg8Q@mail.gmail.com>
	<20130529225419.GA6475@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: dev <dev@openvswitch.org>,
	Network Development <netdev@vger.kernel.org>,
	Jesse Gross <jesse@nicira.com>,
	Pravin B Shelar <pshelar@nicira.com>,
	"jarno.rajahalme" <jarno.rajahalme@nsn.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	=?ISO-8859-2?Q?Maciej_=AFenczykowski?= <maze@google.com>,
	David Miller <davem@davemloft.net>
To: Simon Horman <horms@verge.net.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f43.google.com ([209.85.216.43]:47484 "EHLO
	mail-qa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S966322Ab3E2XCO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 May 2013 19:02:14 -0400
Received: by mail-qa0-f43.google.com with SMTP id j11so2562258qag.16
        for <netdev@vger.kernel.org>; Wed, 29 May 2013 16:02:13 -0700 (PDT)
In-Reply-To: <20130529225419.GA6475@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Wed, May 29, 2013 at 3:54 PM, Simon Horman <horms@verge.net.au> wrote:
> On Wed, May 29, 2013 at 02:46:05PM -0700, Olof Johansson wrote:
>> Sorry, that was not a great bug report.
>>
>> So, looks like it's the removal of NET_SKBUFF_DATA_USES_OFFSET that
>> does it for me.
>>
>> The devices I've seen it with are with asix usb-ethernet adapters (on
>> Tegra seaboard) and with mv643xx_eth on cubox (dove).
>>
>> I'll try to get a better stacktrace out of it. Simon, maybe you can
>> reproduce on shmobile hardware?
>
> Sure, I will try and reproduce it.
>
> I did subsequently post some fixes for fallout resulting from
> the patch listed below. Those changes are now net-next.
> Are you seeing the crash with those patches?
>
> The fix-up patches are:
>
> net,ipv4,ipv6: Correct assignment of skb->network_header to skb->tail
> sctp: Correct access to skb->{network,transport}_header
> ipv4: Correct comparisons and calculations using skb->tail and skb-transport_header
> ipv6: Correct comparisons and calculations using skb->tail and skb-transport_header
> net: Correct comparisons and calculations using skb->tail and skb-transport_header
> cxgb3: Correct comparisons and calculations using skb->tail and skb-transport_header
> isdn: Correct comparison of skb->tail and skb-transport_header
> net: Fix build warnings after mac_header and transport_header became __u16.

Ah, no, looks like those didn't make it into the 0529 linux-next.

I've merged net-next on top and retested, and I no longer see the panics.


Thanks!


-Olof
