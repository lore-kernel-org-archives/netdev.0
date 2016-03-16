From: roopa <roopa@cumulusnetworks.com>
Subject: Re: [PATCH net-next 1/2] rtnetlink: add new RTM_GETSTATS message
 to dump link stats
Date: Tue, 15 Mar 2016 23:44:39 -0700
Message-ID: <56E900D7.20908@cumulusnetworks.com>
References: <1457834186-45727-2-git-send-email-roopa@cumulusnetworks.com> <56E6D224.5020701@6wind.com> <56E7AC06.8040905@cumulusnetworks.com> <56E7C5D9.8080107@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, jhs@mojatatu.com, davem@davemloft.net,
	Eric Dumazet <eric.dumazet@gmail.com>
To: nicolas.dichtel@6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f170.google.com ([209.85.192.170]:36488 "EHLO
	mail-pf0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934590AbcCPGom (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Mar 2016 02:44:42 -0400
Received: by mail-pf0-f170.google.com with SMTP id u190so62518460pfb.3
        for <netdev@vger.kernel.org>; Tue, 15 Mar 2016 23:44:41 -0700 (PDT)
In-Reply-To: <56E7C5D9.8080107@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 3/15/16, 1:20 AM, Nicolas Dichtel wrote:
> Le 15/03/2016 07:30, roopa a =C3=A9crit :
>> On 3/14/16, 8:00 AM, Nicolas Dichtel wrote:
>>> Le 13/03/2016 02:56, Roopa Prabhu a =C3=A9crit :
> [snip]
>>>> diff --git a/include/uapi/linux/rtnetlink.h b/include/uapi/linux/r=
tnetlink.h
>>>> index ca764b5..2bbb300 100644
>>>> --- a/include/uapi/linux/rtnetlink.h
>>>> +++ b/include/uapi/linux/rtnetlink.h
>>>> @@ -139,6 +139,13 @@ enum {
>>>>        RTM_GETNSID =3D 90,
>>>>    #define RTM_GETNSID RTM_GETNSID
>>>>
>>>> +    RTM_NEWSTATS =3D 92,
>>>> +#define RTM_NEWSTATS RTM_NEWSTATS
>>>> +    RTM_DELSTATS =3D 93,
>>>> +#define RTM_DELSTATS RTM_DELSTATS
>>> RTM_DELSTATS is never used.
>>
>> yeah, i had to define it just because rtnetlink_rcv_msg seems to exp=
ect all three to be
>> there when it tries to check if it is a get msg. But, i could sure n=
ot declare this
>> but make rtnetlink_rcv_msg happy by keeping the GET msg at the right=
 offset.
> Not sure to understand what is the problem.
> Look at RTM_NEWNETCONF/RTM_GETNETCONF, there is no DEL command.

yep, same thing as RTM_NEWNETCONF, there is no DEL but GET becomes +2.
I was trying to say that I can do the same also. will drop DEL and make=
 GET
RTM_NEWSTATS + 2.  will take care of it in v2. thanks.

>
>>>
>>>> +    RTM_GETSTATS =3D 94,
>>>> +#define RTM_GETSTATS RTM_GETSTATS
>>>> +
>>>>        __RTM_MAX,
>>>>    #define RTM_MAX        (((__RTM_MAX + 3) & ~3) - 1)
>>>>    };
>>>> diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
>>>> index d2d9e5e..d1e3d17 100644
>>>> --- a/net/core/rtnetlink.c
>>>> +++ b/net/core/rtnetlink.c
>>> [snip]
>>>> +static noinline size_t if_nlmsg_stats_size(const struct net_devic=
e *dev,
>>>> +                       u32 filter_mask)
>>> Why are you using the 'noinline' attribute?
>>
>> I actually picked it up from if_nlmsg_size ...
> If there is no better reason, I suggest to remove it ;-)
> It was introduced by Eric (commit 9e34a5b51684 ("net/core: EXPORT_SYM=
BOL
> cleanups").
> Eric, do you remember why you add this 'noinline' attribute?
>
