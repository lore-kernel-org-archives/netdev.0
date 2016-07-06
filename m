From: Paul Moore <paul@paul-moore.com>
Subject: Re: Network hang after c3f1010b30f7fc611139cfb702a8685741aa6827 with
 CIPSO & Smack
Date: Wed, 6 Jul 2016 10:37:53 -0400
Message-ID: <CAHC9VhTzG1tzfkyCQL++M2USPnZmxoOeuo23qoLjdgtPan9D2w@mail.gmail.com>
References: <e5ba1ba9-acf6-c36c-03e4-4cdc81e81648@schaufler-ca.com>
 <CAHC9VhQsJoA3856MZgaJaHwGAcnXCoe0hn2AtEikcCTZx46Jsg@mail.gmail.com> <822cf1e1-7a76-5b79-d277-f151e66b3693@schaufler-ca.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>, dsa@cumulusnetworks.com,
	Linux-Netdev <netdev@vger.kernel.org>
To: Casey Schaufler <casey@schaufler-ca.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f45.google.com ([209.85.218.45]:34293 "EHLO
	mail-oi0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754184AbcGFOi3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jul 2016 10:38:29 -0400
Received: by mail-oi0-f45.google.com with SMTP id s66so272875883oif.1
        for <netdev@vger.kernel.org>; Wed, 06 Jul 2016 07:37:55 -0700 (PDT)
In-Reply-To: <822cf1e1-7a76-5b79-d277-f151e66b3693@schaufler-ca.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 6, 2016 at 10:15 AM, Casey Schaufler <casey@schaufler-ca.com> wrote:
> On 7/6/2016 5:50 AM, Paul Moore wrote:
>> On Tue, Jul 5, 2016 at 8:38 PM, Casey Schaufler <casey@schaufler-ca.com> wrote:
>>> I have encountered a system hang with my Smack
>>> networking tests that bisects to the change below.
>>> I can't say that I have any idea why the change
>>> would impact the Smack processing, but there appears
>>> to be some serious packet processing going on. The
>>> Smack code is using CIPSO on the loopback interface.
>>> The test is supposed to verify that labels can be
>>> set on the packets using CIPSO. Unlabeled packets
>>> do not appear to be impacted. I do not know if SELinux
>>> is affected, and if not, why not. Smack and SELinux
>>> use CIPSO differently.
>> For the past several months I've been running the SELinux testsuite on
>> a weekly basis against Linus' kernel plus the SELinux and audit
>> development trees and I haven't noticed any problems that haven't
>> already been reported.  While not exhaustive, the testsuite does
>> exercise the NetLabel/CIPSO code.  I'll see if I can take a closer
>> look at the Smack code, but do you rely on the inet_skb_param values
>> in Smack?  We did have a similar problem in the NetLabel core code
>> that we fixed with 04f81f0154e4bf002be6f4d85668ce1257efa4d9; it's
>> possible there is a similar problem in code that we just aren't
>> exercising with SELinux at the moment.
>
> I reported that problem, and that problem was fixed.

Yep, I know, that is why I included the commit ID.

> I'm looking at the Linus tree and see no structure inet_skb_param.

I mistakenly added an extra "a", look for "struct inet_skb_parm" near
the top of include/net/ip.h; it was modified as part of the
pull-request/merge you mentioned.

-- 
paul moore
www.paul-moore.com
