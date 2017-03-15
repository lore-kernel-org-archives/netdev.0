From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [patch net-next v2 1/9] net: fib_rules: Check if selector matches
 all packets
Date: Wed, 15 Mar 2017 09:33:14 -0600
Message-ID: <c4523a1f-ef6a-ac6d-17f9-066feb55067c@cumulusnetworks.com>
References: <1489575912-6469-1-git-send-email-jiri@resnulli.us>
 <1489575912-6469-2-git-send-email-jiri@resnulli.us>
 <27c557ac-5905-5004-8264-1ceba0ad76c6@cumulusnetworks.com>
 <20170315153031.GA30399@splinter.mtl.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org,
        davem@davemloft.net, idosch@mellanox.com, mlxsw@mellanox.com,
        shm@cumulusnetworks.com, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
        yoshfuji@linux-ipv6.org, kaber@trash.net, lorenzo@google.com,
        mateusz.bajorski@nokia.com
To: Ido Schimmel <idosch@idosch.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f51.google.com ([74.125.83.51]:35631 "EHLO
        mail-pg0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753162AbdCOPdS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 15 Mar 2017 11:33:18 -0400
Received: by mail-pg0-f51.google.com with SMTP id b129so10718227pgc.2
        for <netdev@vger.kernel.org>; Wed, 15 Mar 2017 08:33:17 -0700 (PDT)
In-Reply-To: <20170315153031.GA30399@splinter.mtl.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 3/15/17 9:30 AM, Ido Schimmel wrote:
>>> diff --git a/net/ipv4/fib_rules.c b/net/ipv4/fib_rules.c
>>> index 2892109..7a941a5 100644
>>> --- a/net/ipv4/fib_rules.c
>>> +++ b/net/ipv4/fib_rules.c
>>> @@ -47,6 +47,16 @@ struct fib4_rule {
>>>  #endif
>>>  };
>>>  
>>> +bool fib4_rule_matchall(const struct fib_rule *rule)
>>> +{
>>> +	struct fib4_rule *r = (struct fib4_rule *) rule;
>> Use container_of instead of typecast.
> There are multiple conversions from 'fib_rule' to 'fib4_rule' in this
> file, all use typecast.

understood. dst to rtable/rt6_info has the same problem. Rather than
continuing with the typecast, new code should use container_of and older
code can be converted in time.
