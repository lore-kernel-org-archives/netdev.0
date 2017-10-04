From: Eyal Birger <eyal.birger@gmail.com>
Subject: Re: [PATCH net] net: fib_rules: Fix fib_rules_ops->compare
 implementations to support exact match
Date: Wed, 4 Oct 2017 06:58:37 +0300
Message-ID: <CAHsH6Gstsm7smQZ3A0qxfSsWvquT4HrLmMRzGae9L2Wcm7-Bbg@mail.gmail.com>
References: <20170930085909.1103-1-shmulik@nsof.io> <20171003.145418.677435703318514230.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: shmulik@nsof.io, "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        mateusz.bajorski@nokia.com, dsa@cumulusnetworks.com, tgraf@suug.ch,
        Shmulik Ladkani <shmulik.ladkani@gmail.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f68.google.com ([209.85.218.68]:36153 "EHLO
        mail-oi0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751171AbdJDD6i (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 3 Oct 2017 23:58:38 -0400
Received: by mail-oi0-f68.google.com with SMTP id p187so3793530oif.3
        for <netdev@vger.kernel.org>; Tue, 03 Oct 2017 20:58:38 -0700 (PDT)
In-Reply-To: <20171003.145418.677435703318514230.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

On Wed, Oct 4, 2017 at 12:54 AM, David Miller <davem@davemloft.net> wrote:
> From: Shmulik Ladkani <shmulik@nsof.io>
> Date: Sat, 30 Sep 2017 11:59:09 +0300
>
>> This leads to inconsistencies, depending on order of operations, e.g.:
>
> I don't see any inconsistency.  When you insert using NLM_F_EXCL the
> insertion fails if any existing rule matches or overlaps in any way
> with the keys in the new rule.
>
> Sorry I'm not going to apply this.

The inconsistency we saw is that 0.0.0.0/0 is treated differently compared to
all other subnets - for which overlaps are not disallowed - e.g. this succeeds:

# ip ru add from 10.0.0.0/8 iif eth2 pref 33 table 33
# ip ru add from 0.0.0.0/1 iif eth2 pref 33 table 33
# ip ru add from 128.0.0.0/1 iif eth2 pref 33 table 33

Though being functionally equivalent to adding from=0.0.0.0/0.

So our understanding was that 'different subnet==different rule', similar to the
route addition behavior with NLM_F_EXCL.

Best regards,
Eyal.
