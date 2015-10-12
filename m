From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH net-next] net: Fix vti use case with oif in dst lookups
 for IPv6
Date: Mon, 12 Oct 2015 12:49:29 -0600
Message-ID: <561C00B9.1020301@cumulusnetworks.com>
References: <1444055571-82546-1-git-send-email-dsa@cumulusnetworks.com>
 <m2a8rs7crl.wl@gmail.com> <20151009071710.GJ7701@secunet.com>
 <5617F908.8060807@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Hajime Tazaki <thehajime@gmail.com>, netdev@vger.kernel.org
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:35894 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751535AbbJLSts (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Oct 2015 14:49:48 -0400
Received: by pacex6 with SMTP id ex6so6736265pac.3
        for <netdev@vger.kernel.org>; Mon, 12 Oct 2015 11:49:47 -0700 (PDT)
In-Reply-To: <5617F908.8060807@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/9/15 11:27 AM, David Ahern wrote:
> On 10/9/15 1:17 AM, Steffen Klassert wrote:
>>>> diff --git a/net/ipv6/xfrm6_policy.c b/net/ipv6/xfrm6_policy.c
>>>> index 30caa289c5db..5cedfda4b241 100644
>>>> --- a/net/ipv6/xfrm6_policy.c
>>>> +++ b/net/ipv6/xfrm6_policy.c
>>>> @@ -37,6 +37,7 @@ static struct dst_entry *xfrm6_dst_lookup(struct
>>>> net *net, int tos, int oif,
>>>>
>>>>       memset(&fl6, 0, sizeof(fl6));
>>>>       fl6.flowi6_oif = oif;
>>>> +    fl6.flowi6_flags = FLOWI_FLAG_SKIP_NH_OIF;
>>>>       memcpy(&fl6.daddr, daddr, sizeof(fl6.daddr));
>>>>       if (saddr)
>>>>           memcpy(&fl6.saddr, saddr, sizeof(fl6.saddr));
>>>
>>> I found that this fix is still not sufficient with the mip6
>>> (Mobile IPv6) use case.
>>
>> It does not even fix the vti case. The behaviour of the vti devices is
>> the same, with and without the patch.
>>
>
> The attached patch applied to Linus' tree works for me. Currently the
> above change is not in his tree, so I added it to this patch. Once you
> confirm that it works for you I'll create the delta-patch for net and
> send out.

Steffen: Have you had a chance to try the patch? Does it solve the vti6 
problem for you?

David
