From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net 1/2] ipv6: add missing netconf notif when 'all' is
 updated
Date: Mon, 29 Aug 2016 19:50:42 +0300
Message-ID: <e878cb1d-82ab-d7e6-b375-970ff0926ce1@cogentembedded.com>
References: <1472465149-1163-1-git-send-email-nicolas.dichtel@6wind.com>
 <705293f5-0965-8d1c-1539-b70cbed6aea9@cogentembedded.com>
 <CAPA1RqC1r0wDk31Bd7idkQpq4-qwE3wExy9o3s7eeA4D46teFw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Cc: Nicolas Dichtel <nicolas.dichtel@6wind.com>,
        David Miller <davem@davemloft.net>,
        network dev <netdev@vger.kernel.org>
To: =?UTF-8?B?5ZCJ6Jek6Iux5piO?= <hideaki.yoshifuji@miraclelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f50.google.com ([209.85.215.50]:36015 "EHLO
        mail-lf0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753029AbcH2Qvt (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 29 Aug 2016 12:51:49 -0400
Received: by mail-lf0-f50.google.com with SMTP id g62so105009013lfe.3
        for <netdev@vger.kernel.org>; Mon, 29 Aug 2016 09:50:46 -0700 (PDT)
In-Reply-To: <CAPA1RqC1r0wDk31Bd7idkQpq4-qwE3wExy9o3s7eeA4D46teFw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/29/2016 05:13 PM, 吉藤英明 wrote:

>>> The 'default' value was not advertised.
>>>
>>> Fixes: f3a1bfb11ccb ("rtnl/ipv6: use netconf msg to advertise forwarding
>>> status")
>>> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
>>> ---
>>>  net/ipv6/addrconf.c | 7 +++++++
>>>  1 file changed, 7 insertions(+)
>>>
>>> diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
>>> index f418d2eaeddd..299f0656e87f 100644
>>> --- a/net/ipv6/addrconf.c
>>> +++ b/net/ipv6/addrconf.c
>>> @@ -778,7 +778,14 @@ static int addrconf_fixup_forwarding(struct ctl_table
>>> *table, int *p, int newf)
>>>         }
>>>
>>>         if (p == &net->ipv6.devconf_all->forwarding) {
>>> +               int old_dftl = net->ipv6.devconf_dflt->forwarding;
>>> +
>>>                 net->ipv6.devconf_dflt->forwarding = newf;
>>> +               if ((!newf) ^ (!old_dftl))
>>
>>
>>    IIUC, !'s are not necessary here (and more so the parens around them).
>> And perhaps ^ can be changed to != for clarity...
>
> No, it will break.

    Well, if those variables are actually bit masks, ! seem to be needed 
indeed. But ^ can be replaced by != anyway.

> --yoshfuji

MBR, Sergei
