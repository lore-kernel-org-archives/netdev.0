From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH net-next 0/3] l3mdev: Improve use with main table
Date: Thu, 20 Apr 2017 16:36:59 -0600
Message-ID: <3bdb570e-4d7d-6e5c-3270-0bf0064ef73a@cumulusnetworks.com>
References: <1491834122-26252-1-git-send-email-rshearma@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Robert Shearman <rshearma@brocade.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f42.google.com ([209.85.218.42]:34685 "EHLO
        mail-oi0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S939254AbdDTWhC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 20 Apr 2017 18:37:02 -0400
Received: by mail-oi0-f42.google.com with SMTP id x184so71475552oia.1
        for <netdev@vger.kernel.org>; Thu, 20 Apr 2017 15:37:02 -0700 (PDT)
In-Reply-To: <1491834122-26252-1-git-send-email-rshearma@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4/10/17 8:21 AM, Robert Shearman wrote:
> Attempting to create a TCP socket not bound to a VRF device when a TCP
> socket bound to a VRF device with the same port exists (and vice
> versa) fails with EADDRINUSE. This limits the ability to use programs
> in selected mixed VRF/non-VRF contexts.
> 
> This patch series solves the problem by extending the l3mdev be aware
> of the special semantics of the main table and fixing issues arising
> from the split local/main tables. A VRF master device created linking
> to the main table and used for these programs in the same way as those
> created for VRF tables can.
> 
> Robert Shearman (3):
>   ipv6: Fix route handling when using l3mdev set to main table
>   ipv4: Fix route handling when using l3mdev set to main table
>   l3mdev: Fix lookup in local table when using main table
> 
>  net/ipv4/af_inet.c      |  4 +++-
>  net/ipv4/fib_frontend.c | 14 +++++++++-----
>  net/ipv4/raw.c          |  5 ++++-
>  net/ipv6/addrconf.c     | 12 +++++++++---
>  net/ipv6/route.c        | 23 ++++++++++++++++++-----
>  net/l3mdev/l3mdev.c     | 26 ++++++++++++++++++++------
>  6 files changed, 63 insertions(+), 21 deletions(-)
> 

With the change I mentioned earlier to fix the refcnt issue on top of
this patch set I see a number of failures:
- local IPv4 with 127.0.0.1 address - ping, tcp, udp tests fail
- all of the IPv4 multicast tests fail
- IPv6 linklocal and mcast addresses generally fail
- IPv6 global address on vrf device
