From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH net] net: fib_rules: Fix fib_rules_ops->compare
 implementations to support exact match
Date: Tue, 3 Oct 2017 21:40:19 -0700
Message-ID: <c9e417f5-1d55-7443-cad6-e08f76755ab8@cumulusnetworks.com>
References: <20170930085909.1103-1-shmulik@nsof.io>
 <20171003.145418.677435703318514230.davem@davemloft.net>
 <CAHsH6Gstsm7smQZ3A0qxfSsWvquT4HrLmMRzGae9L2Wcm7-Bbg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: shmulik@nsof.io, "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        mateusz.bajorski@nokia.com, tgraf@suug.ch,
        Shmulik Ladkani <shmulik.ladkani@gmail.com>
To: Eyal Birger <eyal.birger@gmail.com>,
        David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f53.google.com ([74.125.83.53]:46505 "EHLO
        mail-pg0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750909AbdJDEk0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 4 Oct 2017 00:40:26 -0400
Received: by mail-pg0-f53.google.com with SMTP id k7so944877pga.3
        for <netdev@vger.kernel.org>; Tue, 03 Oct 2017 21:40:26 -0700 (PDT)
In-Reply-To: <CAHsH6Gstsm7smQZ3A0qxfSsWvquT4HrLmMRzGae9L2Wcm7-Bbg@mail.gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/3/17 8:58 PM, Eyal Birger wrote:
> Hi David,
> 
> On Wed, Oct 4, 2017 at 12:54 AM, David Miller <davem@davemloft.net> wrote:
>> From: Shmulik Ladkani <shmulik@nsof.io>
>> Date: Sat, 30 Sep 2017 11:59:09 +0300
>>
>>> This leads to inconsistencies, depending on order of operations, e.g.:
>>
>> I don't see any inconsistency.  When you insert using NLM_F_EXCL the
>> insertion fails if any existing rule matches or overlaps in any way
>> with the keys in the new rule.
>>
>> Sorry I'm not going to apply this.
> 
> The inconsistency we saw is that 0.0.0.0/0 is treated differently compared to
> all other subnets - for which overlaps are not disallowed - e.g. this succeeds:
> 
> # ip ru add from 10.0.0.0/8 iif eth2 pref 33 table 33
> # ip ru add from 0.0.0.0/1 iif eth2 pref 33 table 33
> # ip ru add from 128.0.0.0/1 iif eth2 pref 33 table 33
> 
> Though being functionally equivalent to adding from=0.0.0.0/0.
> 
> So our understanding was that 'different subnet==different rule', similar to the
> route addition behavior with NLM_F_EXCL.
>

I agree with DaveM ... your "non-working" sequence has a specific entry
followed by a global, match all entry.
