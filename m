From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH v2] net: Require exact match for TCP socket lookups if dif
 is l3mdev
Date: Fri, 14 Oct 2016 06:21:19 -0600
Message-ID: <25e3a7a9-a74e-5392-742a-38bd224343f6@cumulusnetworks.com>
References: <1476420459-20966-1-git-send-email-dsa@cumulusnetworks.com>
 <1476426789.5650.34.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:34559 "EHLO
        mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753542AbcJNMVX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 14 Oct 2016 08:21:23 -0400
Received: by mail-pa0-f48.google.com with SMTP id rz1so47151290pab.1
        for <netdev@vger.kernel.org>; Fri, 14 Oct 2016 05:21:22 -0700 (PDT)
In-Reply-To: <1476426789.5650.34.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/14/16 12:33 AM, Eric Dumazet wrote:
> There is a catch here.
> TCP moves IP6CB() in a different location.
> 
> Reference :
> 
> 971f10eca186 ("tcp: better TCP_SKB_CB layout to reduce cache line misses")

thanks for the reference.


> Problem is that the lookup can happen from IP early demux, before TCP
> moved IP{6}CB around.

For TCP we only need the exact_dif match for listen sockets, so early demux does not apply.

> 
> So you might need to let the caller pass IP6CB(skb)->flags (or
> TCP_SKB_CB(skb)->header.h6.flags ) instead of skb since
> inet6_exact_dif_match() does not know where to fetch the flags.
> 
> Same issue for IPv4.

I'll update the match functions to pull from TCP_SKB_CB instead of IP6CB and make a note of the above.

Thanks for the review
