From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v3] net: ipv4: add support for ECMP hash
 policy choice
Date: Thu, 16 Mar 2017 20:36:03 -0700 (PDT)
Message-ID: <20170316.203603.382155320913663365.davem@davemloft.net>
References: <20170314132506.6233b1e7@xeon-e3>
        <20170314.172424.1077779028779735713.davem@davemloft.net>
        <CALx6S34UWgOcKKvnq32FKLnXpXDitDR+t1s8GmhMBnNAQHLTSw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: stephen@networkplumber.org, nikolay@cumulusnetworks.com,
        netdev@vger.kernel.org, roopa@cumulusnetworks.com,
        dsa@cumulusnetworks.com, jkbs@redhat.com, edumazet@google.com,
        pch@ordbogen.com
To: tom@herbertland.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:54600 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752253AbdCQDpR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 16 Mar 2017 23:45:17 -0400
In-Reply-To: <CALx6S34UWgOcKKvnq32FKLnXpXDitDR+t1s8GmhMBnNAQHLTSw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <tom@herbertland.com>
Date: Tue, 14 Mar 2017 19:30:47 -0700

> Agreed, but then why do we even need any complexity here by that
> argument? RSS is specifically defined to do 5-tuple hashing for TCP
> (and UDP), and 3-tuple. No one has ever complained that doing per flow
> RSS for TCP is bad thing AFAIK. We followed that same model for RPS,
> RFS, and XPS via state in the connection context. The skb_hash is
> often given to us for free, whereas in order to do a 3-tuple we have
> to actually do more work and do at least an extra jhash. I suppose the
> argument is probably that switches allow this configuration and
> somehow we want to have feature parity, but it would be very
> interesting to know if anyone is not doing per flow ECMP in real life
> and why...

Anyone doing any kind of hardware offload work requires the
possibility of getting feature parity on the software side.  It's the
only way to properly test and debug things.
