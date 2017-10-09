From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH net] net: enable interface alias removal via rtnl
Date: Mon, 9 Oct 2017 10:23:51 +0200
Message-ID: <6e1671c7-93d7-0090-54f6-6b36abb8ba89@6wind.com>
References: <20171005101940.28550-1-nicolas.dichtel@6wind.com>
 <b6c121f1-c585-6fa4-8dc9-8847ea5ee20c@gmail.com>
 <f6bd73fe-9b60-6741-8a6d-c93f6ee64a40@hartkopp.net>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, Oliver Hartkopp <oliver@hartkopp.net>,
        Stephen Hemminger <stephen@networkplumber.org>
To: Oliver Hartkopp <socketcan@hartkopp.net>,
        David Ahern <dsahern@gmail.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f48.google.com ([74.125.82.48]:45608 "EHLO
        mail-wm0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750795AbdJIIXz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 9 Oct 2017 04:23:55 -0400
Received: by mail-wm0-f48.google.com with SMTP id q124so20225573wmb.0
        for <netdev@vger.kernel.org>; Mon, 09 Oct 2017 01:23:55 -0700 (PDT)
In-Reply-To: <f6bd73fe-9b60-6741-8a6d-c93f6ee64a40@hartkopp.net>
Content-Language: fr
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 06/10/2017 à 22:10, Oliver Hartkopp a écrit :
> 
> 
> On 10/06/2017 08:18 PM, David Ahern wrote:
>> On 10/5/17 4:19 AM, Nicolas Dichtel wrote:
>>> IFLA_IFALIAS is defined as NLA_STRING. It means that the minimal length of
>>> the attribute is 1 ("\0"). However, to remove an alias, the attribute
>>> length must be 0 (see dev_set_alias()).
>>
>> why not add a check in dev_set_alias that if len is 1 and the 1
>> character is '\0' it means remove the alias?
Because it requires an iproute2 patch. iproute2 doesn't send the '\0'. With the
command 'ip link set dummy0 alias ""', the attribute length is 0.
A kernel patch is probably enough for this problem. Updating iproute2 on old
distributions is not always easy.

> 
> Yes. That looks indeed better than changing NLA_STRING to NLA_BINARY which does
> not really hit the point.
> 
> Nicolas, can you send an updated patch picking up David's suggestion?
> 
> Tnx & best regards,
> Oliver
> 
>>
>>>
>>> Let's define the type to NLA_BINARY, so that the alias can be removed.
>>
>> that changes the uapi
>>
I don't understand what will be broken.
