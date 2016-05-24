From: Tom Herbert <tom@herbertland.com>
Subject: Re: [RFC PATCH 7/7] tou: Support for GSO
Date: Tue, 24 May 2016 10:07:07 -0700
Message-ID: <CALx6S35Hzf35myKq-c=jwg7Fzwdsu_SYtKYDD9SuVnG=Db4obQ@mail.gmail.com>
References: <1464043706-2843932-1-git-send-email-tom@herbertland.com>
	<1464043706-2843932-8-git-send-email-tom@herbertland.com>
	<CAKgT0Udjj=_7-Ye5yGUkie9o5AVN0+mvi1D1dEJRkcbzKm35sA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>, Kernel Team <kernel-team@fb.com>
To: Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f196.google.com ([209.85.223.196]:36456 "EHLO
	mail-io0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751997AbcEXRHI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 May 2016 13:07:08 -0400
Received: by mail-io0-f196.google.com with SMTP id m17so2019377ioi.3
        for <netdev@vger.kernel.org>; Tue, 24 May 2016 10:07:07 -0700 (PDT)
In-Reply-To: <CAKgT0Udjj=_7-Ye5yGUkie9o5AVN0+mvi1D1dEJRkcbzKm35sA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 24, 2016 at 7:59 AM, Alexander Duyck
<alexander.duyck@gmail.com> wrote:
> On Mon, May 23, 2016 at 3:48 PM, Tom Herbert <tom@herbertland.com> wrote:
>> Add SKB_GSO_TOU. In udp[64]_ufo_fragment check for SKB_GSO_TOU. If this
>> is set call skb_udp_tou_segment. skb_udp_tou_segment is very similar
>> to skb_udp_tunnel_segment except that we only need to deal with the
>> L4 headers.
>>
>> Signed-off-by: Tom Herbert <tom@herbertland.com>
>> ---
>>  include/linux/skbuff.h           |   2 +
>>  include/net/udp.h                |   2 +
>>  net/ipv4/fou.c                   |   2 +
>>  net/ipv4/ip_output.c             |   2 +
>>  net/ipv4/udp_offload.c           | 164 +++++++++++++++++++++++++++++++++++++--
>>  net/ipv6/inet6_connection_sock.c |   3 +
>>  net/ipv6/udp_offload.c           | 128 +++++++++++++++---------------
>>  7 files changed, 236 insertions(+), 67 deletions(-)
>>
>> diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
>> index 65968a9..b57e484 100644
>> --- a/include/linux/skbuff.h
>> +++ b/include/linux/skbuff.h
>> @@ -482,6 +482,8 @@ enum {
>>         SKB_GSO_PARTIAL = 1 << 13,
>>
>>         SKB_GSO_TUNNEL_REMCSUM = 1 << 14,
>> +
>> +       SKB_GSO_TOU = 1 << 15,
>>  };
>>
>
> So where do you add the netdev feature bit?  From what I can tell that
> was overlooked and as a result devices that support FCoE CRC will end
> up corrupting TOU frames because netif_gso_ok currently ands the two
> together.
>
An obvious omission, thanks for pointing it out.

> Also I am pretty sure we can offload this on the Intel NICs using the
> GSO partial approach as we can just stuff the UDP header into the
> space that we would use for IPv4 options or IPv6 extension headers and
> it shouldn't complain.
>
That would be cool!

> - Alex
