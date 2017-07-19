From: David Ahern <dsahern@gmail.com>
Subject: Re: [patch net-next 11/17] ipv6: fib: Allow non-FIB users to take
 reference on route
Date: Wed, 19 Jul 2017 10:29:14 -0600
Message-ID: <ad7666d8-ede5-9518-e169-3f5f6f0b6798@gmail.com>
References: <20170719070232.28457-1-jiri@resnulli.us>
 <20170719070232.28457-12-jiri@resnulli.us>
 <606f31c5-c5f9-193a-9527-6e47f827dd75@gmail.com>
 <20170719161727.GC6078@splinter>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org,
        davem@davemloft.net, mlxsw@mellanox.com, roopa@cumulusnetworks.com,
        nikolay@cumulusnetworks.com, kafai@fb.com,
        hannes@stressinduktion.org, yoshfuji@linux-ipv6.org,
        edumazet@google.com, yanhaishuang@cmss.chinamobile.com
To: Ido Schimmel <idosch@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f51.google.com ([74.125.83.51]:37566 "EHLO
        mail-pg0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753659AbdGSQ3R (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 19 Jul 2017 12:29:17 -0400
Received: by mail-pg0-f51.google.com with SMTP id y129so2376273pgy.4
        for <netdev@vger.kernel.org>; Wed, 19 Jul 2017 09:29:16 -0700 (PDT)
In-Reply-To: <20170719161727.GC6078@splinter>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 7/19/17 10:17 AM, Ido Schimmel wrote:
> I did exactly that in the beginning, but it didn't sit right with me for
> the exact reason you mentioned - it can be a PITA to debug.
> 
> If we use rt6i_ref for something other than FIB references, then it
> breaks existing code that relies on rt6i_ref being 0 to indicate it's
> no longer used by the FIB. A non-zero value can now mean "not used by
> the FIB, but waiting for some module to drop the reference in its
> workqueue".
> 
> The BUG_ON() mentioned in the commit message is just one example.
> Another check was added by you in commit 8048ced9b.
> 
> So I think we both want the same thing, but I'm not sure how your
> approach is safer.

A single reference counter rt6i_ref is best.

There are 2 reads of that counter to determine if the rt is still in the
FIB. Both of those stem from side effects of using the 'lo' for the
device for host addresses. I think an explicit flag can be used for that
purpose instead of trying to deduce it from the reference counter. The
commit you referenced copied what is done in init_loopback for
consistency (both have same end goal).
