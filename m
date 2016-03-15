From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH net-next 1/2] rtnetlink: add new RTM_GETSTATS message to
 dump link stats
Date: Tue, 15 Mar 2016 09:20:41 +0100
Message-ID: <56E7C5D9.8080107@6wind.com>
References: <1457834186-45727-2-git-send-email-roopa@cumulusnetworks.com>
 <56E6D224.5020701@6wind.com> <56E7AC06.8040905@cumulusnetworks.com>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, jhs@mojatatu.com, davem@davemloft.net,
	Eric Dumazet <eric.dumazet@gmail.com>
To: roopa <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f50.google.com ([74.125.82.50]:36255 "EHLO
	mail-wm0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933992AbcCOIUp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Mar 2016 04:20:45 -0400
Received: by mail-wm0-f50.google.com with SMTP id l124so672173wmf.1
        for <netdev@vger.kernel.org>; Tue, 15 Mar 2016 01:20:44 -0700 (PDT)
In-Reply-To: <56E7AC06.8040905@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 15/03/2016 07:30, roopa a =C3=A9crit :
> On 3/14/16, 8:00 AM, Nicolas Dichtel wrote:
>> Le 13/03/2016 02:56, Roopa Prabhu a =C3=A9crit :
[snip]
>>> diff --git a/include/uapi/linux/rtnetlink.h b/include/uapi/linux/rt=
netlink.h
>>> index ca764b5..2bbb300 100644
>>> --- a/include/uapi/linux/rtnetlink.h
>>> +++ b/include/uapi/linux/rtnetlink.h
>>> @@ -139,6 +139,13 @@ enum {
>>>        RTM_GETNSID =3D 90,
>>>    #define RTM_GETNSID RTM_GETNSID
>>>
>>> +    RTM_NEWSTATS =3D 92,
>>> +#define RTM_NEWSTATS RTM_NEWSTATS
>>> +    RTM_DELSTATS =3D 93,
>>> +#define RTM_DELSTATS RTM_DELSTATS
>> RTM_DELSTATS is never used.
>
> yeah, i had to define it just because rtnetlink_rcv_msg seems to expe=
ct all three to be
> there when it tries to check if it is a get msg. But, i could sure no=
t declare this
> but make rtnetlink_rcv_msg happy by keeping the GET msg at the right =
offset.
Not sure to understand what is the problem.
Look at RTM_NEWNETCONF/RTM_GETNETCONF, there is no DEL command.

>>
>>> +    RTM_GETSTATS =3D 94,
>>> +#define RTM_GETSTATS RTM_GETSTATS
>>> +
>>>        __RTM_MAX,
>>>    #define RTM_MAX        (((__RTM_MAX + 3) & ~3) - 1)
>>>    };
>>> diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
>>> index d2d9e5e..d1e3d17 100644
>>> --- a/net/core/rtnetlink.c
>>> +++ b/net/core/rtnetlink.c
>> [snip]
>>> +static noinline size_t if_nlmsg_stats_size(const struct net_device=
 *dev,
>>> +                       u32 filter_mask)
>> Why are you using the 'noinline' attribute?
>
> I actually picked it up from if_nlmsg_size ...
If there is no better reason, I suggest to remove it ;-)
It was introduced by Eric (commit 9e34a5b51684 ("net/core: EXPORT_SYMBO=
L
cleanups").
Eric, do you remember why you add this 'noinline' attribute?
