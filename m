From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [net-next PATCH v2 0/5] XDP adjust head support for virtio
Date: Wed, 8 Feb 2017 18:50:56 +0200
Message-ID: <20170208184817-mutt-send-email-mst@kernel.org>
References: <20170203031251.23054.25387.stgit@john-Precision-Tower-5810>
 <20170207053455-mutt-send-email-mst@kernel.org>
 <589B49B1.4070304@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kubakici@wp.pl, jasowang@redhat.com, ast@fb.com,
        john.r.fastabend@intel.com, netdev@vger.kernel.org
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:59532 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752529AbdBHQ6a (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 8 Feb 2017 11:58:30 -0500
Content-Disposition: inline
In-Reply-To: <589B49B1.4070304@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Feb 08, 2017 at 08:39:13AM -0800, John Fastabend wrote:
> [...]
> 
> > However, I came up with a new idea for the future and I'd like to show
> > where I'm going.  The idea is that we don't use s/g buffers on RX, so we
> > have a pointer per descriptor untapped.  So we can allow users to stick
> > their own pointer in there, if they promise not to use s/g on this vq.
> > With a full extra pointer to play with, we can go wild.
> 
> I looked at this quickly it seems like it would work and allow us to avoid
> the reset. However, it seems like a lot of churn to avoid a single reset.
> I don't see the reset itself as being that bad of an operation. I agree the
> reset is not ideal though.
> 
> Are there any other use cases for this other than XDP?

Well in fact this would allow reducing MERGEABLE_BUFFER_ALIGN
to L1_CACHE_BYTES so we save space per packet for regular
networking.

The idea to use build_skb would also benefit accordingly.

I guess ndo_set_rx_headroom could benefit if we were to implement that.



> > 
> > Take a look but it doesn't even build yet.
> > Need to roll it out to all devices etc.
> > 
> > --->
> > 
> 
> [...]
