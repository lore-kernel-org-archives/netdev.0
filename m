From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH net-next v3] net: ipv4: add support for ECMP hash policy
 choice
Date: Tue, 14 Mar 2017 08:55:02 -0700
Message-ID: <20170314085502.47d48a4e@xeon-e3>
References: <1488884508-14016-1-git-send-email-nikolay@cumulusnetworks.com>
        <1489505775-2913-1-git-send-email-nikolay@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
        roopa@cumulusnetworks.com, dsa@cumulusnetworks.com,
        jkbs@redhat.com, edumazet@google.com, pch@ordbogen.com
To: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f54.google.com ([74.125.83.54]:35702 "EHLO
        mail-pg0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751245AbdCNPzV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 14 Mar 2017 11:55:21 -0400
Received: by mail-pg0-f54.google.com with SMTP id b129so92702106pgc.2
        for <netdev@vger.kernel.org>; Tue, 14 Mar 2017 08:55:20 -0700 (PDT)
In-Reply-To: <1489505775-2913-1-git-send-email-nikolay@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 14 Mar 2017 17:36:15 +0200
Nikolay Aleksandrov <nikolay@cumulusnetworks.com> wrote:

> This patch adds support for ECMP hash policy choice via a new sysctl
> called fib_multipath_hash_policy and also adds support for L4 hashes.
> The current values for fib_multipath_hash_policy are:
>  0 - layer 3 (default)
>  1 - layer 4
> If there's an skb hash already set and it matches the chosen policy then it
> will be used instead of being calculated (currently only for L4).
> In L3 mode we always calculate the hash due to the ICMP error special
> case, the flow dissector's field consistentification should handle the
> address order thus we can remove the address reversals.
> 
> Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>

It is good to see ECMP come back from the grave.
Linux used to support it long ago but was abandoned after it was unstable
and removed from iproute2 in 2012.

The old API was through route attributes which makes more sense than
doing it with sysctl. It makes more sense to use netlink instead.
Therefore please go back and do something like the old API rather than doing it through
sysctl.
