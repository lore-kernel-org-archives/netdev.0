From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH net-next] net: Fix vti use case with oif in dst lookups
 for IPv6
Date: Fri, 9 Oct 2015 09:53:46 -0600
Message-ID: <5617E30A.8030804@cumulusnetworks.com>
References: <1444055571-82546-1-git-send-email-dsa@cumulusnetworks.com>
 <m2a8rs7crl.wl@gmail.com> <20151009071710.GJ7701@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Steffen Klassert <steffen.klassert@secunet.com>,
	Hajime Tazaki <thehajime@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:35787 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932244AbbJIPxl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Oct 2015 11:53:41 -0400
Received: by pabve7 with SMTP id ve7so31605024pab.2
        for <netdev@vger.kernel.org>; Fri, 09 Oct 2015 08:53:40 -0700 (PDT)
In-Reply-To: <20151009071710.GJ7701@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/9/15 1:17 AM, Steffen Klassert wrote:
> On Fri, Oct 09, 2015 at 03:54:22PM +0900, Hajime Tazaki wrote:
>>
>> Hello David,
>>
>> At Mon,  5 Oct 2015 08:32:51 -0600,
>> David Ahern wrote:
>>
>>>
>>> diff --git a/net/ipv6/xfrm6_policy.c b/net/ipv6/xfrm6_policy.c
>>> index 30caa289c5db..5cedfda4b241 100644
>>> --- a/net/ipv6/xfrm6_policy.c
>>> +++ b/net/ipv6/xfrm6_policy.c
>>> @@ -37,6 +37,7 @@ static struct dst_entry *xfrm6_dst_lookup(struct net *net, int tos, int oif,
>>>
>>>   	memset(&fl6, 0, sizeof(fl6));
>>>   	fl6.flowi6_oif = oif;
>>> +	fl6.flowi6_flags = FLOWI_FLAG_SKIP_NH_OIF;
>>>   	memcpy(&fl6.daddr, daddr, sizeof(fl6.daddr));
>>>   	if (saddr)
>>>   		memcpy(&fl6.saddr, saddr, sizeof(fl6.saddr));
>>
>> I found that this fix is still not sufficient with the mip6
>> (Mobile IPv6) use case.
>
> It does not even fix the vti case. The behaviour of the vti devices is
> the same, with and without the patch.
>

I goofed this patch was on top of my IPv6 VRF patches. You need the 
FLOWI_FLAG_SKIP_NH_OIF bits from:

     http://www.spinics.net/lists/netdev/msg346860.html

Let me cook up a patch based on Linus' tree which is where it is needed.
