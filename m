From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH net-next] virtio-net: invoke zerocopy callback on xmit
 path if no tx napi
Date: Tue, 29 Aug 2017 23:40:49 +0300
Message-ID: <20170829233920-mutt-send-email-mst@kernel.org>
References: <CAF=yD-KSek+LmZu0X0TXetmFEQ59iF3NpjZ4KugbwLo1BGfhaA@mail.gmail.com>
 <20170824160748-mutt-send-email-mst@kernel.org>
 <CAF=yD-+9Ah8pC9i2w3Ad3WnhQit7Yo479pMrToty7priL6BFLw@mail.gmail.com>
 <20170824234551-mutt-send-email-mst@kernel.org>
 <CAF=yD-+1wheMmC+HFKe_B_ULO0Mmh6HMSEbYY5D-HgqxVJee6A@mail.gmail.com>
 <20170826022744-mutt-send-email-mst@kernel.org>
 <CAF=yD-Lre0NATUVH8p0zS=G5CiY=WfKSefLmOZw940jZFgECgQ@mail.gmail.com>
 <CAF=yD-+Wk9sc9dXMUq1+x_hh=3ThTXa6BnZkygP3tgVpjbp93g@mail.gmail.com>
 <20170829224136-mutt-send-email-mst@kernel.org>
 <CAF=yD-L5MG5RCZzT8EZ0coFiuQLp-2UQN0zzQefVnEd7rMQbyw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Koichiro Den <den@klaipeden.com>, Jason Wang <jasowang@redhat.com>,
        virtualization@lists.linux-foundation.org,
        Network Development <netdev@vger.kernel.org>
To: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:48898 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751249AbdH2Uku (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 29 Aug 2017 16:40:50 -0400
Content-Disposition: inline
In-Reply-To: <CAF=yD-L5MG5RCZzT8EZ0coFiuQLp-2UQN0zzQefVnEd7rMQbyw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 29, 2017 at 03:53:08PM -0400, Willem de Bruijn wrote:
> On Tue, Aug 29, 2017 at 3:42 PM, Michael S. Tsirkin <mst@redhat.com> wrote:
> > On Tue, Aug 29, 2017 at 03:35:38PM -0400, Willem de Bruijn wrote:
> >> By the way, I have had an unrelated patch outstanding for a while
> >> to have virtio-net support the VIRTIO_CONFIG_S_NEEDS_RESET
> >> command. Will send that as RFC.
> >
> > Oh nice.
> 
> Great :)
> 
> > One needs to be careful about locking there which is why
> > no devices support that yet.
> 
> I originally wrote it based on the virtnet_reset function introduced
> for xdp. Calling this from virtnet_config_changed_work is non trivial,
> as virtnet_freeze_down waits until no config worker is running.
> 
> Otherwise, I could not find any constraints on when freeze may be
> called, and it largely follows the same path. I hope I didn't miss anything.

The issue is that on freeze processes are not running so we
generally know no new packets will arrive (might be wrong
for bridging, then it's a bug). On device error you must
prevent new skbs from coming in, etc.

-- 
MST
