From: Krishna Kumar2 <krkumar2@in.ibm.com>
Subject: Re: [PATCH 2/4] [RFC] virtio: Introduce new API to get free space
Date: Thu, 5 May 2011 08:38:19 +0530
Message-ID: <OF13F1641F.3317FDBB-ON65257887.0010EA23-65257887.0010FFB7@in.ibm.com>
References: <20110504140258.14817.66596.sendpatchset@krkumar2.in.ibm.com> <20110504140319.14817.23145.sendpatchset@krkumar2.in.ibm.com> <20110504145019.GB15823@redhat.com> <20110504200023.GA20303@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: davem@davemloft.net, eric.dumazet@gmail.com, kvm@vger.kernel.org,
	netdev@vger.kernel.org, rusty@rustcorp.com.au
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e28smtp02.in.ibm.com ([122.248.162.2]:36943 "EHLO
	e28smtp02.in.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752741Ab1EEDFp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 May 2011 23:05:45 -0400
In-Reply-To: <20110504200023.GA20303@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

"Michael S. Tsirkin" <mst@redhat.com> wrote on 05/05/2011 01:30:23 AM:

> > > @@ -185,11 +193,6 @@ int virtqueue_add_buf_gfp(struct virtque
> > >     if (vq->num_free < out + in) {
> > >        pr_debug("Can't add buf len %i - avail = %i\n",
> > >            out + in, vq->num_free);
> > > -      /* FIXME: for historical reasons, we force a notify here if
> > > -       * there are outgoing parts to the buffer.  Presumably the
> > > -       * host should service the ring ASAP. */
> > > -      if (out)
> > > -         vq->notify(&vq->vq);
> > >        END_USE(vq);
> > >        return -ENOSPC;
> > >     }
> >
> > This will break qemu versions 0.13 and back.
> > I'm adding some new virtio ring flags, we'll be
> > able to reuse one of these to mean 'no need for
> > work around', I think.
>
> Not really, it wont. We shall almost never get here at all.
> But then, why would this help performance?

Yes, it is not needed. I will be testing it without this
also.

thanks,

- KK

