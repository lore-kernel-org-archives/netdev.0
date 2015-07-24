From: Hangbin Liu <liuhangbin@gmail.com>
Subject: Re: [PATCH] net/ipv6: add sysctl option accept_ra_hop_limit
Date: Fri, 24 Jul 2015 19:12:16 +0800
Message-ID: <CAPwn2JQv3JNDTEsYo3ce9BPOTdwOGqE1SfBRv28rE+Z2kdvixQ@mail.gmail.com>
References: <1437709989-30041-1-git-send-email-liuhangbin@gmail.com>
	<55B1C38C.2000903@miraclelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: network dev <netdev@vger.kernel.org>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>
To: YOSHIFUJI Hideaki <hideaki.yoshifuji@miraclelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f49.google.com ([209.85.218.49]:33493 "EHLO
	mail-oi0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751882AbbGXLMR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Jul 2015 07:12:17 -0400
Received: by oige126 with SMTP id e126so15826780oig.0
        for <netdev@vger.kernel.org>; Fri, 24 Jul 2015 04:12:16 -0700 (PDT)
In-Reply-To: <55B1C38C.2000903@miraclelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2015-07-24 12:48 GMT+08:00 YOSHIFUJI Hideaki
<hideaki.yoshifuji@miraclelinux.com>:
> Hi,
>
> Hangbin Liu wrote:
>> Commit 6fd99094de2b ("ipv6: Don't reduce hop limit for an interface")
>> disabled accept hop limit from RA if it is higher than the current hop
>> limit for security stuff. But this behavior kind of break the RFC definition.
>>
>> RFC 4861, 6.3.4.  Processing Received Router Advertisements
>>    If the received Cur Hop Limit value is non-zero, the host SHOULD set
>>    its CurHopLimit variable to the received value.
>>
>> So add sysctl option accept_ra_hop_limit to let user choose whether accept
>> hop limit info in RA.
>>
>> Signed-off-by: Hangbin Liu <liuhangbin@gmail.com>
>> Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
>> ---
>>  Documentation/networking/ip-sysctl.txt | 11 +++++++++++
>>  include/linux/ipv6.h                   |  1 +
>>  include/uapi/linux/ipv6.h              |  1 +
>>  net/ipv6/addrconf.c                    | 10 ++++++++++
>>  net/ipv6/ndisc.c                       | 17 +++++++++++------
>>  5 files changed, 34 insertions(+), 6 deletions(-)
>>
> :
>> diff --git a/include/uapi/linux/ipv6.h b/include/uapi/linux/ipv6.h
>> index 5efa54a..9f40ac9 100644
>> --- a/include/uapi/linux/ipv6.h
>> +++ b/include/uapi/linux/ipv6.h
>> @@ -153,6 +153,7 @@ enum {
>>       DEVCONF_FORCE_MLD_VERSION,
>>       DEVCONF_ACCEPT_RA_DEFRTR,
>>       DEVCONF_ACCEPT_RA_PINFO,
>> +     DEVCONF_ACCEPT_RA_HOP_LIMIT,
>>       DEVCONF_ACCEPT_RA_RTR_PREF,
>>       DEVCONF_RTR_PROBE_INTERVAL,
>>       DEVCONF_ACCEPT_RA_RT_INFO_MAX_PLEN,
>
> No, you cannot add new one in the middle of these since
> values are exported to userspace.
>
Hi Yoshfuji-san,

Thanks for the reminding, should I also move the value in struct ipv6_devconf
to the end or just leave after accept_ra_pinfo?

Thanks
Hangbin
