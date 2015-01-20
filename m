From: Tom Herbert <therbert@google.com>
Subject: Re: [PATCH net-next 2/2] vxlan: Eliminate dependency on UDP socket in
 transmit path
Date: Tue, 20 Jan 2015 09:29:42 -0800
Message-ID: <CA+mtBx-QVcK2yP7hwr01X-KaXedzrgMGrHH503-i5y54BPnNPA@mail.gmail.com>
References: <1421518700-22460-1-git-send-email-therbert@google.com>
	<1421518700-22460-3-git-send-email-therbert@google.com>
	<20150119085938.GG20315@casper.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f177.google.com ([209.85.223.177]:40894 "EHLO
	mail-ie0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755187AbbATR3n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Jan 2015 12:29:43 -0500
Received: by mail-ie0-f177.google.com with SMTP id at20so11633339iec.8
        for <netdev@vger.kernel.org>; Tue, 20 Jan 2015 09:29:42 -0800 (PST)
In-Reply-To: <20150119085938.GG20315@casper.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 19, 2015 at 12:59 AM, Thomas Graf <tgraf@suug.ch> wrote:
> On 01/17/15 at 10:18am, Tom Herbert wrote:
>> diff --git a/include/net/vxlan.h b/include/net/vxlan.h
>> index 7be8c34..2927d62 100644
>> --- a/include/net/vxlan.h
>> +++ b/include/net/vxlan.h
>> @@ -129,8 +129,12 @@ struct vxlan_sock {
>>  #define VXLAN_F_REMCSUM_RX           0x400
>>  #define VXLAN_F_GBP                  0x800
>>
>> -/* These flags must match in order for a socket to be shareable */
>> -#define VXLAN_F_UNSHAREABLE          VXLAN_F_GBP
>> +/* Flags that are used in the receive patch. These flags must match in
>                                           ^^^^^
>
>
>
>> + * order for a socket to be shareable
>> + */
>> +#define VXLAN_F_RCV_FLAGS            (VXLAN_F_GBP |                  \
>> +                                      VXLAN_F_UDP_ZERO_CSUM6_RX |    \
>> +                                      VXLAN_F_REMCSUM_RX)
>
> I'm fine with this. It is slightly odd that we will be transmitting
> RCO and other extensions on UDP ports which cannot accept the same
> frames. I assume you have specific use cases for this scenario.

I didn't see any reason to preclude that, if it needs to be symmetric
in that case it can be forced at the configuration. Being able to
receive RCO but not have to send it to certain peers is important use
case. You may want to consider this also for GBP if there are cases
where we accept GBP from different peers, but only send it to certain
ones.

Tom
