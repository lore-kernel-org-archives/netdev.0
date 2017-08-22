From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH net-next] virtio-net: invoke zerocopy callback on xmit
 path if no tx napi
Date: Tue, 22 Aug 2017 21:39:24 +0300
Message-ID: <20170822213229-mutt-send-email-mst@kernel.org>
References: <CAF=yD-LZ4=WAYfUtY7xRWi50FRSkrcOa+b7uc46xRnC4sbDCzQ@mail.gmail.com>
 <64d451ae-9944-e978-5a05-54bb1a62aaad@redhat.com>
 <20170822204015-mutt-send-email-mst@kernel.org>
 <20170822.110108.343109469263087166.davem@davemloft.net>
 <1503426508.2499.47.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, jasowang@redhat.com,
        willemdebruijn.kernel@gmail.com, den@klaipeden.com,
        virtualization@lists.linux-foundation.org, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:46254 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751969AbdHVSj0 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 22 Aug 2017 14:39:26 -0400
Content-Disposition: inline
In-Reply-To: <1503426508.2499.47.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 22, 2017 at 11:28:28AM -0700, Eric Dumazet wrote:
> On Tue, 2017-08-22 at 11:01 -0700, David Miller wrote:
> > From: "Michael S. Tsirkin" <mst@redhat.com>
> > Date: Tue, 22 Aug 2017 20:55:56 +0300
> > 
> > > Which reminds me that skb_linearize in net core seems to be
> > > fundamentally racy - I suspect that if skb is cloned, and someone is
> > > trying to use the shared frags while another thread calls skb_linearize,
> > > we get some use after free bugs which likely mostly go undetected
> > > because the corrupted packets mostly go on wire and get dropped
> > > by checksum code.
> > 
> > Indeed, it does assume that the skb from which the clone was made
> > never has it's geometry changed.
> > 
> > I don't think even the TCP retransmit queue has this guarantee.
> 
> TCP retransmit makes sure to avoid that.
> 
> if (skb_unclone(skb, GFP_ATOMIC))
>      return -ENOMEM;
> 
> ( Before cloning again skb )
> 
> 

I'm pretty sure not all users of skb_clone or generally
__pskb_pull_tail are careful like this.

E.g. skb_cow_data actually intentionally pulls pages when
skb is cloned.


-- 
MST
