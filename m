From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH 2/4] [RFC] virtio: Introduce new API to get free space
Date: Thu, 5 May 2011 12:13:17 +0300
Message-ID: <20110505091317.GA28335@redhat.com>
References: <20110504140258.14817.66596.sendpatchset@krkumar2.in.ibm.com>
 <20110504140319.14817.23145.sendpatchset@krkumar2.in.ibm.com>
 <20110504145019.GB15823@redhat.com>
 <20110504200023.GA20303@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, eric.dumazet@gmail.com, kvm@vger.kernel.org,
	netdev@vger.kernel.org, rusty@rustcorp.com.au
To: Krishna Kumar <krkumar2@in.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:41895 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752155Ab1EEJNi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 May 2011 05:13:38 -0400
Content-Disposition: inline
In-Reply-To: <20110504200023.GA20303@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 04, 2011 at 11:00:23PM +0300, Michael S. Tsirkin wrote:
> On Wed, May 04, 2011 at 05:50:19PM +0300, Michael S. Tsirkin wrote:
> > > @@ -185,11 +193,6 @@ int virtqueue_add_buf_gfp(struct virtque
> > >  	if (vq->num_free < out + in) {
> > >  		pr_debug("Can't add buf len %i - avail = %i\n",
> > >  			 out + in, vq->num_free);
> > > -		/* FIXME: for historical reasons, we force a notify here if
> > > -		 * there are outgoing parts to the buffer.  Presumably the
> > > -		 * host should service the ring ASAP. */
> > > -		if (out)
> > > -			vq->notify(&vq->vq);
> > >  		END_USE(vq);
> > >  		return -ENOSPC;
> > >  	}
> > 
> > This will break qemu versions 0.13 and back.
> > I'm adding some new virtio ring flags, we'll be
> > able to reuse one of these to mean 'no need for
> > work around', I think.
> 
> Not really, it wont. We shall almost never get here at all.
> But then, why would this help performance?

I think I understand this finally.
By itself, this patch does not help performance and does not
hurt it. But later patch makes us try to xmit and fail there
instead of doing capacity checks. With *that* patch applied
on top of this one, and with qemu 0.13 and older, performance
will be hurt.

We need to either
- ignore these older hosts
- add a feature bit (or use one of the new ones I added: for example
  with avail_event userspace never needs this behaviour as it can
  ask to get events when ring gets full)
- keep doing capacity checks, which will make us almost never get here


> > -- 
> > MST
