From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] virtio-net: invoke zerocopy callback on xmit
 path if no tx napi
Date: Tue, 22 Aug 2017 11:01:08 -0700 (PDT)
Message-ID: <20170822.110108.343109469263087166.davem@davemloft.net>
References: <CAF=yD-LZ4=WAYfUtY7xRWi50FRSkrcOa+b7uc46xRnC4sbDCzQ@mail.gmail.com>
        <64d451ae-9944-e978-5a05-54bb1a62aaad@redhat.com>
        <20170822204015-mutt-send-email-mst@kernel.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jasowang@redhat.com, willemdebruijn.kernel@gmail.com,
        den@klaipeden.com, virtualization@lists.linux-foundation.org,
        netdev@vger.kernel.org
To: mst@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:39200 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751909AbdHVSBJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 22 Aug 2017 14:01:09 -0400
In-Reply-To: <20170822204015-mutt-send-email-mst@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Michael S. Tsirkin" <mst@redhat.com>
Date: Tue, 22 Aug 2017 20:55:56 +0300

> Which reminds me that skb_linearize in net core seems to be
> fundamentally racy - I suspect that if skb is cloned, and someone is
> trying to use the shared frags while another thread calls skb_linearize,
> we get some use after free bugs which likely mostly go undetected
> because the corrupted packets mostly go on wire and get dropped
> by checksum code.

Indeed, it does assume that the skb from which the clone was made
never has it's geometry changed.

I don't think even the TCP retransmit queue has this guarantee.
