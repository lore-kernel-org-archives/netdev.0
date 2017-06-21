From: Serhey Popovych <serhe.popovych@gmail.com>
Subject: Re: fib_rules: Resolve goto rules target on delete
Date: Wed, 21 Jun 2017 10:44:47 +0300
Message-ID: <11d8ff28-a667-8d2d-9b90-304ee76ee94a@gmail.com>
References: <1497617087-26386-1-git-send-email-serhe.popovych@gmail.com>
 <20170620.124040.491492963882254347.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f68.google.com ([209.85.215.68]:34845 "EHLO
        mail-lf0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750876AbdFUHov (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 21 Jun 2017 03:44:51 -0400
Received: by mail-lf0-f68.google.com with SMTP id n136so7639754lfn.2
        for <netdev@vger.kernel.org>; Wed, 21 Jun 2017 00:44:50 -0700 (PDT)
Received: from tuxracer.local ([195.238.92.77])
        by smtp.gmail.com with ESMTPSA id 131sm3528845ljf.29.2017.06.21.00.44.48
        for <netdev@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 21 Jun 2017 00:44:48 -0700 (PDT)
In-Reply-To: <20170620.124040.491492963882254347.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> From: Serhey Popovych <serhe.popovych@gmail.com>
> Date: Fri, 16 Jun 2017 15:44:47 +0300
> 
>> We should avoid marking goto rules unresolved when their
>> target is actually reachable after rule deletion.
>>
>> Consolder following sample scenario:
>>
>>   # ip -4 ru sh
>>   0:      from all lookup local
>>   32000:  from all goto 32100
>>   32100:  from all lookup main
>>   32100:  from all lookup default
>>   32766:  from all lookup main
>>   32767:  from all lookup default
>>
>>   # ip -4 ru del pref 32100 table main
>>   # ip -4 ru sh
>>   0:      from all lookup local
>>   32000:  from all goto 32100 [unresolved]
>>   32100:  from all lookup default
>>   32766:  from all lookup main
>>   32767:  from all lookup default
>>
>> After removal of first rule with preference 32100 we
>> mark all goto rules as unreachable, even when rule with
>> same preference as removed one still present.
>>
>> Check if next rule with same preference is available
>> and make all rules with goto action pointing to it.
>>
>> Signed-off-by: Serhey Popovych <serhe.popovych@gmail.com>
> 
> Applied, thanks.
> 
> It would be awesome if you could distill the above into a test case that
> could be run under tools/testing/selftests/networking.
Yes, I already think about testing too.

Actually I have series of  patches to improve fib_rules support both in
core and per protocol (merge suppress, callback, reduce per network
namespace memory consumption - useful for docker setups, more precise
validation of netlink configuration messages, additional matching
facilities etc) so testing is  definitely required before my changes
went upstream!

About testing implementation: I see there is no infrastructure
to test netlink based configuration in tools/testing. How to make
this better? Use libnl, write scripts that use iproute2 utilities?
Where I can get additional to Documentation/kselftest.txt information?

> 
> Thanks!
> 

-- 
Thanks, Serhey
