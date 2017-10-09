From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH net] net: enable interface alias removal via rtnl
Date: Mon, 9 Oct 2017 17:25:47 +0200
Message-ID: <3e705d90-9b9a-aa02-e1d9-e3a944953014@6wind.com>
References: <20171005101940.28550-1-nicolas.dichtel@6wind.com>
 <b6c121f1-c585-6fa4-8dc9-8847ea5ee20c@gmail.com>
 <f6bd73fe-9b60-6741-8a6d-c93f6ee64a40@hartkopp.net>
 <6e1671c7-93d7-0090-54f6-6b36abb8ba89@6wind.com>
 <ffd17810-8d65-04f5-6841-98c74201780c@gmail.com>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, Oliver Hartkopp <oliver@hartkopp.net>,
        Stephen Hemminger <stephen@networkplumber.org>
To: David Ahern <dsahern@gmail.com>,
        Oliver Hartkopp <socketcan@hartkopp.net>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f51.google.com ([74.125.82.51]:56578 "EHLO
        mail-wm0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754818AbdJIPZu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 9 Oct 2017 11:25:50 -0400
Received: by mail-wm0-f51.google.com with SMTP id l68so24497129wmd.5
        for <netdev@vger.kernel.org>; Mon, 09 Oct 2017 08:25:49 -0700 (PDT)
In-Reply-To: <ffd17810-8d65-04f5-6841-98c74201780c@gmail.com>
Content-Language: fr
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 09/10/2017 à 16:02, David Ahern a écrit :
> On 10/9/17 2:23 AM, Nicolas Dichtel wrote:
>> Le 06/10/2017 à 22:10, Oliver Hartkopp a écrit :
>>>
>>>
>>> On 10/06/2017 08:18 PM, David Ahern wrote:
>>>> On 10/5/17 4:19 AM, Nicolas Dichtel wrote:
>>>>> IFLA_IFALIAS is defined as NLA_STRING. It means that the minimal length of
>>>>> the attribute is 1 ("\0"). However, to remove an alias, the attribute
>>>>> length must be 0 (see dev_set_alias()).
>>>>
>>>> why not add a check in dev_set_alias that if len is 1 and the 1
>>>> character is '\0' it means remove the alias?
>> Because it requires an iproute2 patch. iproute2 doesn't send the '\0'. With the
>> command 'ip link set dummy0 alias ""', the attribute length is 0.
> 
> iproute2 needs the feature for 0-len strings or perhaps a 'noalias' option.
iproute2 needs nothing ...

> 
> You can reset the alias using the sysfs file. Given that there is a
> workaround for existing kernels and userspace, upstream can get fixed
> without changing the UAPI.
> 
I don't get the point with the UAPI. What will be broken?
I don't see why allowing an attribute with no data is a problem.
