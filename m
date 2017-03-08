From: Jakub Sitnicki <jkbs@redhat.com>
Subject: Re: [PATCH net-next v2] net: ipv4: add support for ECMP hash policy choice
Date: Wed, 08 Mar 2017 13:05:36 +0100
Message-ID: <878togdldb.fsf@redhat.com>
References: <1488884508-14016-1-git-send-email-nikolay@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org, edumazet@google.com, davem@davemloft.net,
        roopa@cumulusnetworks.com, dsa@cumulusnetworks.com
To: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f172.google.com ([209.85.128.172]:34520 "EHLO
        mail-wr0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750745AbdCHMHa (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 8 Mar 2017 07:07:30 -0500
Received: by mail-wr0-f172.google.com with SMTP id l37so21798208wrc.1
        for <netdev@vger.kernel.org>; Wed, 08 Mar 2017 04:05:39 -0800 (PST)
In-reply-to: <1488884508-14016-1-git-send-email-nikolay@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Nikolay,

On Tue, Mar 07, 2017 at 11:01 AM GMT, Nikolay Aleksandrov wrote:
> This patch adds support for ECMP hash policy choice via a new sysctl
> called fib_multipath_hash_policy and also adds support for L4 hashes.
> The current values for fib_multipath_hash_policy are:
>  0 - layer 3 (default)
>  1 - layer 4
> If there's an skb hash already set and it matches the chosen policy then it
> will be used instead of being calculated. The ICMP inner IP addresses use
> is removed.
>
> Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
> ---
> v2:
>  - removed the output_key_hash as it's not needed anymore
>  - reverted to my original/internal patch with L3 as default hash

What about ICMP PTB (Fragmentation Needed) forwarding that makes PMTUD
work with ECMP in setups like described in RFC7690 [1]?

  ptb -> router ecmp -> next hop L4/L7 load balancer -> destination

       router --> load balancer 1 --->
            \\--> load balancer 2 ---> load-balanced service
             \--> load balancer N --->

Removing special treatment of ICMP errors will break it, won't it?

FWIW, I gave a run to your patch (default settings, L3 hash) with a test
script [2] that simulates such a setup and it confirmed my worries - PTB
errors don't travel back to the source host any more.

-Jakub

[1] https://tools.ietf.org/html/rfc7690#section-2
[2] https://github.com/jsitnicki/tools/commit/ccb85e68421df4ffd8b7abf00f6f5fe1c6a5af76
