From: Oliver Hartkopp <socketcan@hartkopp.net>
Subject: Re: [PATCH net] net: enable interface alias removal via rtnl
Date: Fri, 6 Oct 2017 22:10:42 +0200
Message-ID: <f6bd73fe-9b60-6741-8a6d-c93f6ee64a40@hartkopp.net>
References: <20171005101940.28550-1-nicolas.dichtel@6wind.com>
 <b6c121f1-c585-6fa4-8dc9-8847ea5ee20c@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Oliver Hartkopp <oliver@hartkopp.net>,
        Stephen Hemminger <stephen@networkplumber.org>
To: David Ahern <dsahern@gmail.com>,
        Nicolas Dichtel <nicolas.dichtel@6wind.com>,
        davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo4-p00-ob.smtp.rzone.de ([81.169.146.218]:34235 "EHLO
        mo4-p00-ob.smtp.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751649AbdJFUQ4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 6 Oct 2017 16:16:56 -0400
In-Reply-To: <b6c121f1-c585-6fa4-8dc9-8847ea5ee20c@gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 10/06/2017 08:18 PM, David Ahern wrote:
> On 10/5/17 4:19 AM, Nicolas Dichtel wrote:
>> IFLA_IFALIAS is defined as NLA_STRING. It means that the minimal length of
>> the attribute is 1 ("\0"). However, to remove an alias, the attribute
>> length must be 0 (see dev_set_alias()).
> 
> why not add a check in dev_set_alias that if len is 1 and the 1
> character is '\0' it means remove the alias?

Yes. That looks indeed better than changing NLA_STRING to NLA_BINARY 
which does not really hit the point.

Nicolas, can you send an updated patch picking up David's suggestion?

Tnx & best regards,
Oliver

> 
>>
>> Let's define the type to NLA_BINARY, so that the alias can be removed.
> 
> that changes the uapi
> 
