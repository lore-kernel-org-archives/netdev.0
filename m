From: =?UTF-8?B?5ZCJ6Jek6Iux5piO?= <hideaki.yoshifuji@miraclelinux.com>
Subject: Re: [PATCH net 1/2] ipv6: add missing netconf notif when 'all' is updated
Date: Mon, 29 Aug 2016 23:13:30 +0900
Message-ID: <CAPA1RqC1r0wDk31Bd7idkQpq4-qwE3wExy9o3s7eeA4D46teFw@mail.gmail.com>
References: <1472465149-1163-1-git-send-email-nicolas.dichtel@6wind.com> <705293f5-0965-8d1c-1539-b70cbed6aea9@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Nicolas Dichtel <nicolas.dichtel@6wind.com>,
        David Miller <davem@davemloft.net>,
        network dev <netdev@vger.kernel.org>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f43.google.com ([209.85.214.43]:38385 "EHLO
        mail-it0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932942AbcH2ONb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 29 Aug 2016 10:13:31 -0400
Received: by mail-it0-f43.google.com with SMTP id g62so98595980ith.1
        for <netdev@vger.kernel.org>; Mon, 29 Aug 2016 07:13:30 -0700 (PDT)
In-Reply-To: <705293f5-0965-8d1c-1539-b70cbed6aea9@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

2016-08-29 22:00 GMT+09:00 Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>:
> Hello.
>
> On 8/29/2016 1:05 PM, Nicolas Dichtel wrote:
>
>> The 'default' value was not advertised.
>>
>> Fixes: f3a1bfb11ccb ("rtnl/ipv6: use netconf msg to advertise forwarding
>> status")
>> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
>> ---
>>  net/ipv6/addrconf.c | 7 +++++++
>>  1 file changed, 7 insertions(+)
>>
>> diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
>> index f418d2eaeddd..299f0656e87f 100644
>> --- a/net/ipv6/addrconf.c
>> +++ b/net/ipv6/addrconf.c
>> @@ -778,7 +778,14 @@ static int addrconf_fixup_forwarding(struct ctl_table
>> *table, int *p, int newf)
>>         }
>>
>>         if (p == &net->ipv6.devconf_all->forwarding) {
>> +               int old_dftl = net->ipv6.devconf_dflt->forwarding;
>> +
>>                 net->ipv6.devconf_dflt->forwarding = newf;
>> +               if ((!newf) ^ (!old_dftl))
>
>
>    IIUC, !'s are not necessary here (and more so the parens around them).
> And perhaps ^ can be changed to != for clarity...

No, it will break.

--yoshfuji
