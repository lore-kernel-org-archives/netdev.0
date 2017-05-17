From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ipv6: Prevent overrun when parsing v6 header
 options
Date: Wed, 17 May 2017 14:57:30 -0400 (EDT)
Message-ID: <20170517.145730.76726417606716563.davem@davemloft.net>
References: <20170516183623.84966-1-kraigatgoog@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: andreyknvl@google.com, netdev@vger.kernel.org
To: kraigatgoog@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:35506 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750944AbdEQS5u (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 17 May 2017 14:57:50 -0400
In-Reply-To: <20170516183623.84966-1-kraigatgoog@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Craig Gallek <kraigatgoog@gmail.com>
Date: Tue, 16 May 2017 14:36:23 -0400

> From: Craig Gallek <kraig@google.com>
> 
> The KASAN warning repoted below was discovered with a syzkaller
> program.  The reproducer is basically:
>   int s = socket(AF_INET6, SOCK_RAW, NEXTHDR_HOP);
>   send(s, &one_byte_of_data, 1, MSG_MORE);
>   send(s, &more_than_mtu_bytes_data, 2000, 0);
> 
> The socket() call sets the nexthdr field of the v6 header to
> NEXTHDR_HOP, the first send call primes the payload with a non zero
> byte of data, and the second send call triggers the fragmentation path.
> 
> The fragmentation code tries to parse the header options in order
> to figure out where to insert the fragment option.  Since nexthdr points
> to an invalid option, the calculation of the size of the network header
> can made to be much larger than the linear section of the skb and data
> is read outside of it.
> 
> This fix makes ip6_find_1stfrag return an error if it detects
> running out-of-bounds.
 ...
> Reported-by: Andrey Konovalov <andreyknvl@google.com>
> Signed-off-by: Craig Gallek <kraig@google.com>

Since this is a reasonably serious bug I'm going to apply this
to 'net' and queue it up for -stable.

Thanks.
