From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: Re: [PATCH net-next] net: ipv4: add support for ECMP hash policy
 choice
Date: Mon, 06 Mar 2017 22:16:00 -0800
Message-ID: <58BE5020.5010209@cumulusnetworks.com>
References: <1488812370-24800-1-git-send-email-nikolay@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@google.com, davem@davemloft.net,
        dsa@cumulusnetworks.com
To: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f54.google.com ([74.125.83.54]:34922 "EHLO
        mail-pg0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755222AbdCGIwU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 7 Mar 2017 03:52:20 -0500
Received: by mail-pg0-f54.google.com with SMTP id b129so76659515pgc.2
        for <netdev@vger.kernel.org>; Tue, 07 Mar 2017 00:51:02 -0800 (PST)
In-Reply-To: <1488812370-24800-1-git-send-email-nikolay@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 3/6/17, 6:59 AM, Nikolay Aleksandrov wrote:
> This patch adds support for ECMP hash policy choice via a new sysctl
> called fib_multipath_hash_policy and also adds support for L4 hashes.
> The current values for fib_multipath_hash_policy are:
>  0 - layer 3
>  1 - layer 4 (new default)
> If there's an skb hash already set and it matches the chosen policy then it
> will be used instead of being calculated. The ICMP inner IP addresses use
> is removed, and we switch to L4 default for better distribution.
>
> Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
> ---
> I'm not happy with using an integer, but it produces the smallest churn.
> Just let me know if you'd like to switch to a string sysctl.
>
to confirm, this makes ipv4 same as the default ecmp hashing in ipv6.
but ipv6 also has the flow label to help in some cases.

If we decide to move to l4 by default, the sysctl might not be necessary.
and, my only concern with moving to default is if it will upset any existing fragmented
flow distributions. I tried to do some quick survey on other system defaults. Most switches I have
heard of use 5-tuple by default in hw. Will look some more.

We still have the option of not making l4 hash the default (your first internal version). It will make
the ipv4 default different than ipv6 (which is today's state of things and that maybe ok if it is just a sysctl away).
