From: Davide Caratti <dcaratti@redhat.com>
Subject: [PATCH RFC net-next v3 0/7] improve CRC32c in the forwarding path
Date: Fri,  7 Apr 2017 16:16:03 +0200
Message-ID: <cover.1491562390.git.dcaratti@redhat.com>
References: <CALx6S34cSH+z+humkp5s7UHAqnafHHB-GTqobHyb-SfKNe+MiA@mail.gmail.com>
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        linux-sctp@vger.kernel.org
To: Tom Herbert <tom@herbertland.com>,
        Alexander Duyck <alexander.duyck@gmail.com>,
        David Laight <David.Laight@aculab.com>,
        "David S . Miller" <davem@davemloft.net>,
        Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:53186 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754189AbdDGOQW (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 7 Apr 2017 10:16:22 -0400
In-Reply-To: <CALx6S34cSH+z+humkp5s7UHAqnafHHB-GTqobHyb-SfKNe+MiA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2017-03-07 at 10:06 -0800, Alexander Duyck wrote:
> You might even take this one step
> further.  You could convert crc32_csum into a 1 bit enum for now.
> Basically you would use 0 for 1's compliement csum, and 1 to represent
> a crc32c csum.  Then if we end up having to add another bit for
> something like FCoE in the future it would give us 4 possible checksum
> types instead of just giving us 1 with a bit mask.


On Sat, 2017-03-18 at 15:35 -0700, Tom Herbert wrote:
> Just create a non_ip_csum bit in skbuff.
> csum_bad can replaced with this I think. If the bit is set then more
> work can be done to differentiate between alternative checksums.

hello Alexander and Tom,

I refreshed the series including your suggestions.
Some followups are still possible:

* drivers that parse the packet header to correctly resolve CHECKSUM_PARTIAL
(e.g. ixgbe_tx_csum()) can benefit from skb->csum_algo savng some CPU cycles
(e.g. avoiding calling ip_hdr(skb)->protocol or ixgbe_ipv6_csum_is_sctp(skb)).

* drivers that call skb_checksum_help() to resolve CHECKSUM_PARTIAL can
call skb_crc32c_csum_help (or skb_csum_hwoffload_help(skb, 0)) to avoid
wrong CRC on SCTP packets.

thank you in advance for looking at this!
regards,
